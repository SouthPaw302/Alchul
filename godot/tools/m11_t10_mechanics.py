#!/usr/bin/env python3
"""ALCHUL M11 T10: force-balance and corridor/gait feasibility tests.

All inputs are dimensionless fictional mechanical assumptions. No measured body
mass, tissue strength, muscle moment arm, contact surface or settlement width.
Passing math checks means the **toy model** is consistent, not that an extinct
theropod (or the ALCHUL species) could actually perform the behavior.
Python standard library; reproducible, fail-closed analysis.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import math
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
CONFIG=ROOT/'data/m11_t10_force_locomotion_config.json'
RESULT=ROOT/'data/m11_t10_force_locomotion_results.json'
SIDES=('L','R'); DIGITS=('I','II','III')


def norm(v): return math.sqrt(sum(x*x for x in v))
def add(a,b):return tuple(x+y for x,y in zip(a,b))
def sub(a,b):return tuple(x-y for x,y in zip(a,b))
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross2(r,f):return r[0]*f[1]-r[1]*f[0]
def rnd(x):
    if isinstance(x,(float,int)):return round(float(x),6)
    if isinstance(x,(list,tuple)):return [rnd(t) for t in x]
    return x

def verify_config(cfg,rig,previous):
    if cfg.get('status')!='noncanonical_mechanical_feasibility_not_biological_validation':raise ValueError('Biological certainty boundary violated')
    if cfg.get('schema')!='alchul.m11.t10.force-locomotion-assumption.v1':raise ValueError('Wrong T10 contract')
    if previous.get('schema')!='alchul.m11.t08-t09.results.v1':raise ValueError('T08/9 data unavailable')
    if previous.get('status','').find('NOT_FOSSIL_DATA')<0:raise ValueError('T08/9 science uncertainty lost')
    bodies=rig['bodies']
    if {body['id'] for body in bodies}!={'H-A','H-B'}:raise ValueError('Competing candidates lost')
    actual=hashlib.sha256(json.dumps([{'id':b['id'],'bones':b['bones']} for b in bodies],sort_keys=True,separators=(',',':')).encode()).hexdigest()
    if actual!=previous['input_rig_geometry_sha256']:raise ValueError('T07 geometry differs from T08/9 provenance')
    if cfg['locomotion']['retracted_digit'] in cfg['locomotion']['supported_digits']:raise ValueError('Do not assert digit II as supporting by default')
    if sorted(cfg['locomotion']['supported_digits'])!=['III','IV']:raise ValueError('Require provisional dromaeosaur-grade support digits')
    for typ in ('supported_brace','hypothetical_opposing_ring'):
        vals=cfg['grip'][typ]
        for k,v in vals.items():
            if isinstance(v,(int,float)) and (v<0 or not math.isfinite(v)):raise ValueError('Invalid force input: '+k)
    if cfg['locomotion']['assumed_lateral_shift_limit']<=0:raise ValueError('Shift capacity must be disclosed')
    return actual


def anchors(body):return {r['name']:tuple(r['anchor']) for r in body['bones']}


def digit_levers(points):
    # Use *actual archived reference geometry* for second phalanx length.
    # A conservative distal lever upper bound, not a musculoskeletal moment arm.
    return {d:norm(sub(points[f'manual_{d}_2_R'],points[f'manual_{d}_1_R'])) for d in DIGITS}


def brace_solution(values,levers,near_reach,wall=True):
    """Three co-directional fingers oppose a backing wall in a 2D static model.

    Contact positions x=-r and y={-h,0,h}; wall contact x=+r, y=0.
    A mathematically balanced gravity load W is shared half by fingers, half
    by the wall. No force closure is asserted; wall-free direction cannot close.
    """
    W=values['load_bodyweight'];mu=values['finger_mu'];muw=values['support_mu']
    max_n=values['finger_normal_capacity_bw_each']; max_w=values['support_normal_capacity_bw']
    r=values['fixture_half_depth'];h=values['contact_vertical_offset']
    feasible=near_reach and wall and mu>0 and muw>0
    n=max(W/(6*mu),W/(6*muw)) if feasible else 0.0
    # tiny positive numerical buffer ensures strict Coulomb inequalities
    n*=1.00000001
    contacts=[]
    for i,d in enumerate(DIGITS):
        y=(i-1)*h; f=(n,W/6)
        demand=norm(f)*levers[d]
        contacts.append({'digit':d,'position':rnd((-r,y)), 'force':rnd(f),
                         'normal':rnd(n),'tangent':rnd(W/6),
                         'friction_utilization':rnd((W/6)/(mu*n)) if n and mu else None,
                         'distal_joint_torque_upper_proxy':rnd(demand),
                         'torque_limit':values['digit_torque_capacity_bw_length_each']})
    wall_force=(-3*n,W/2) if wall else (0.0,0.0)
    wrench_fx=sum(c['force'][0] for c in contacts)+wall_force[0]
    wrench_fy=sum(c['force'][1] for c in contacts)+wall_force[1]-W
    torque=sum(cross2(c['position'],c['force']) for c in contacts)
    if wall:torque+=cross2((r,0.0),wall_force)
    friction=(n>0 and W/6 <= mu*n+1e-9 and W/2 <= muw*(3*n)+1e-9)
    normal_cap=n<=max_n and 3*n<=max_w
    torque_cap=all(c['distal_joint_torque_upper_proxy']<=values['digit_torque_capacity_bw_length_each']+1e-9 for c in contacts)
    residual=norm((wrench_fx,wrench_fy,torque))
    passed=bool(feasible and friction and normal_cap and torque_cap and residual<1e-5)
    return {'case':'backed_fixture_static_brace','near_reachable_from_T09':near_reach,
            'backing_wall':wall,'equilibrium_feasible_assumed':passed,
            'normal_required_per_digit':rnd(n),'fingers':contacts,
            'support_force':rnd(wall_force),'resultant_wrench_residual':rnd(residual),
            'friction_pass':friction,'normal_strength_pass':normal_cap,'torque_proxy_pass':torque_cap,
            'contact_type':'wall-assisted push. Not an opposable free grasp.',
            'supporting_evidence':'T09 fingertip proximity only; surface normals invented.'}


def ring_solution(values,levers):
    """An *alternative unattested geometry*: three opposing radial contacts.

    Exact 2D wrench equilibrium of gravity+external x load+external torque,
    not general 6D force closure, not demonstrated reachable by the T07 hand.
    Tangential forces derived analytically for 120° evenly spaced normals.
    """
    R=values['radius_normalized'];W=values['tool_weight_bodyweight']
    Fext=(values['disturbance_horizontal_bw'],-W)
    Text=values['disturbance_torque_bw_length'];mu=values['finger_mu']
    normal_max=values['digit_normal_capacity_bw_each'];torque_max=values['digit_torque_capacity_bw_length_each']
    if R<=0 or mu<=0: return {'equilibrium_feasible_conditional':False,'reason':'invalid radius/friction'}
    # equal inward normals cancel in the symmetric arrangement; friction terms
    # counter the external wrench and can include a torque offset.
    tangent=[]
    for i in range(3):
        th=2*math.pi*i/3; t=(-math.sin(th), math.cos(th))
        tangent.append(-(2/3)*dot(t,Fext)-Text/(3*R))
    n_req=max(abs(t) for t in tangent)/mu * 1.00000001
    contacts=[];sumf=[Fext[0],Fext[1]];sumtorque=Text
    for i,d in enumerate(DIGITS):
        th=2*math.pi*i/3;u=(math.cos(th),math.sin(th));t=(-u[1],u[0]);r=(R*u[0],R*u[1]);force=(-n_req*u[0]+tangent[i]*t[0],-n_req*u[1]+tangent[i]*t[1])
        sumf[0]+=force[0];sumf[1]+=force[1];sumtorque+=cross2(r,force)
        load_proxy=norm(force)*levers[d]
        contacts.append({'digit':d,'position':rnd(r),'force':rnd(force),'normal':rnd(n_req),'tangent':rnd(tangent[i]),'joint_torque_upper_proxy':rnd(load_proxy)})
    cap=n_req<=normal_max and all(c['joint_torque_upper_proxy']<=torque_max for c in contacts)
    residual=norm((*sumf,sumtorque))
    return {'case':'hypothetical_ring_three_opposed_contact_directions','equilibrium_feasible_conditional':bool(cap and residual<1e-5),
            'all_three_contacts_reachable_with_T07':False, 'force_closure_verified':False,
            'requires_new_nonhuman_hand_pose_geometry':True,
            'finger_normal_required':rnd(n_req),'torque_capacity_per_digit':torque_max,
            'contacts':contacts, 'residual_wrench':rnd(residual),
            'normal_and_joint_capacity_pass':cap,
            'meaning':'Conditional 2D single-wrench equilibrium on an unattested opposing geometry; NOT actual ALCHUL grip.'}


def footprint_limits(point,spread,foot_half_width,extra=0.0):
    x,z=point
    # local rectangular toe contact assumption; NOT true III/IV skin/ground mesh
    return [x-0.18,x+0.45,spread-foot_half_width-extra,spread+foot_half_width+extra]


def margin(point,box):
    x,z=point
    return min(x-box[0],box[1]-x,z-box[2],box[3]-z)


def step_proxy(points, com, values):
    foot=points['metatarsus_R']; fz=abs(foot[2]); wx=com[0];half=values['foot_half_width'];target=values['support_margin_target']
    foot_box=footprint_limits((foot[0],foot[2]),fz,half)
    required_shift=max(0.0,fz-half+target - com[2]);chosen_shift=required_shift
    shifted=(wx,com[2]+chosen_shift)
    s_margin=margin(shifted,foot_box)
    lim=values['assumed_lateral_shift_limit'];max_lean=math.degrees(math.atan2(chosen_shift,points['pelvis'][1]))
    # effective roll torque about stance center in normalized BW*length, NOT muscle strength
    torque=abs(foot[2]-shifted[1]);torque_pass=torque<=values['stance_leg_torque_capacity_bw_length']
    straight=values['assumed_straight_acceleration_over_g']
    turn=values['assumed_turn_froude']/1.10
    friction_required=max(straight,turn)
    cases=[]
    for name,active,shift in [('double_support_start',['L','R'],0.0),('transfer_to_right',['L','R'],chosen_shift*.5),('right_stance',['R'],chosen_shift),('transfer_to_left',['L','R'],0.0),('left_stance',['L'],-chosen_shift),('double_support_end',['L','R'],0.0)]:
        z=com[2]+shift
        if len(active)==1:
            side=active[0];s=1 if side=='R' else -1
            box=[foot[0]-0.18,foot[0]+0.45,s*fz-half,s*fz+half]
        else:box=[foot[0]-0.18,foot[0]+0.45,-fz-half,fz+half]
        m=margin((wx,z),box)
        cases.append({'phase':name,'contacts':active,'COM_shift_z':rnd(shift),'COM_z':rnd(z),'margin':rnd(m),'within_assumed_contact':m>=-1e-9})
    return {'hip_normalized':points['pelvis'][1],'foot_lateral_offset':rnd(fz),
            'required_com_lateral_shift_for_0p025_margin':rnd(required_shift),
            'implied_body_lean_deg_if_rigid':rnd(max_lean),'shift_limit':lim,
            'required_stance_leg_roll_moment_proxy':rnd(torque),
            'stance_leg_torque_proxy_cap':values['stance_leg_torque_capacity_bw_length'],
            'friction_required_accel_over_g':rnd(friction_required),
            'friction_cases':{label:{'assumed_mu':mu,'no_slip_proxy':mu+1e-9>=friction_required}
                for label,mu in [('wet_stone',values['wet_stone_friction']),('slippery_mud',values['slippery_mud_friction'])]},
            'modelled_shift_feasible':bool(chosen_shift<=lim and torque_pass and s_margin>=0),
            'no_shift_one_foot_inside':margin((wx,com[2]),foot_box)>=0,
            'phases':cases,'warning':'quasi-static phase checklist, not momentum integration or active muscle model'}


def pose_samples(R,n_straight,n_arc):
    # L-turn from west (facing east) to north (facing north), pelvis follows
    # horizontal approach, quarter arc centered (-R,+R), then north exit.
    out=[]
    for i in range(n_straight):
        x=-2.8+(-R+2.8)*i/(n_straight-1)
        out.append((x,0,0))
    for i in range(1,n_arc):
        th=-math.pi/2+(math.pi/2)*(i/(n_arc-1))
        x=-R+R*math.cos(th);z=R+R*math.sin(th)
        heading=th+math.pi/2
        out.append((x,z,heading))
    for i in range(1,n_straight):
        z=R+(2.9-R)*i/(n_straight-1)
        out.append((0,z,math.pi/2))
    return out


def key_points(points,config):
    tail=-min(points[f'caudal_0{i}'][0] for i in range(1,5))
    head=max(points[k][0] for k in ('skull','mandible'))
    w=config['body_half_width'];tw=config['tail_half_width'];hw=config['head_half_width'];extra=config['safety_allowance']
    # Rectangular longitudinal cross-sections of idealized body and tail:
    # sufficient to demonstrate swept clearance but NOT skinned collision mesh.
    stations=[(-tail,tw),(-tail*.75,tw),(-tail*.5,tw),(-tail*.25,w*.65),(-0.45,w),(0,w),(0.65,w),(1.15,w*.85),(head,hw)]
    return [(u,v) for length,width in stations for u,v in [(length, -width-extra),(length,width+extra)]]


def rotate_translate(local,pose):
    x,z,th=pose;u,v=local
    return (x+u*math.cos(th)-v*math.sin(th),z+u*math.sin(th)+v*math.cos(th))


def in_L_corridor(x,z,width):
    h=width/2
    return (x<=h and -h<=z<=h) or (-h<=x<=h and z>=-h)


def turn_clearance(points,params,width):
    samples=pose_samples(params['turn_radius_normalized'],params['samples_straight_per_leg'],params['samples_turn'])
    stations=key_points(points,params)
    violations=[]; worst_out=0
    for frame,pose in enumerate(samples):
        bad=[]
        for p in stations:
            px,pz=rotate_translate(p,pose)
            if not in_L_corridor(px,pz,width):
                bad.append([rnd(px),rnd(pz)])
        if bad:
            violations.append({'sample':frame,'count':len(bad)})
            worst_out=max(worst_out,len(bad))
    return {'corridor_width':width,'violating_samples':len(violations),'total_samples':len(samples),
            'clearance_pass':len(violations)==0,'maximum_outside_sample_point_count':worst_out,
            'first_violating_frame':violations[0]['sample'] if violations else None}


def analyze(config,rig,previous):
    old_hash=verify_config(config,rig,previous)
    result={'schema':'alchul.m11.t10.force-locomotion-result.v1',
      'status':'ASSUMPTION_DRIVEN_MATH_AND_ENGINEERING_CONSISTENCY_NOT_BIOLOGICAL_VALIDATION',
      'scientific_boundary':'Not fitted to any fossil, body tissue, physics engine contact simulation or measured ALCHUL settlement',
      'source_T07_geometry_sha256':old_hash,
      'source_T08_T09_assumptions_sha256':previous['input_assumptions_sha256'],
      'assumptions_sha256':hashlib.sha256(json.dumps(config,sort_keys=True,separators=(',',':')).encode()).hexdigest(),
      'candidates':{}}
    for body in rig['bodies']:
        key=body['id'];p=anchors(body);old=previous['t08'][key];near=previous['t09'][key]['near']
        if not near['all_three_close']:raise ValueError('T09 assumed close proximity not established')
        lever=digit_levers(p)
        b=config['grip']['supported_brace'];r=config['grip']['hypothetical_opposing_ring']
        normal=brace_solution(b,lever,near['all_three_close'],True)
        no_wall=brace_solution(b,lever,near['all_three_close'],False)
        slick=dict(b, finger_mu=0.05,support_mu=0.05)
        weak=dict(b,digit_torque_capacity_bw_length_each=0.001)
        ring=ring_solution(r,lever)
        ring_slick=ring_solution(dict(r,finger_mu=0.08),lever)
        # Use COM (an assumed proxy from preceding actual results), same bone hash.
        com=old['cases']['two_feet_neutral']['com_xyz']
        steps=step_proxy(p,com,config['locomotion'])
        turns=[turn_clearance(p,config['clearance'],w) for w in config['clearance']['corridor_test_widths_normalized']]
        first=next((r['corridor_width'] for r in turns if r['clearance_pass']),None)
        result['candidates'][key]={
            'digit_levers_T07_segment_length':{k:rnd(v) for k,v in lever.items()},
            'force_checks':{'supported_fixture':normal,'unsupported_no_wall':no_wall,
              'slippery_wet_fixture':brace_solution(slick,lever,True,True),
              'very_weak_finger_joint':brace_solution(weak,lever,True,True),
              'hypothetical_ring_clamp':ring,'hypothetical_ring_low_friction':ring_slick},
            'stepping':steps,
            'tail_length_normalized':rnd(-p['caudal_04'][0]),
            'head_length_normalized':rnd(max(p['skull'][0],p['mandible'][0])),
            'corner_clearance':{'radius':config['clearance']['turn_radius_normalized'],
              'width_results':turns,'first_passing_width_IN_TEST_GRID':first,
              'caveat':'Arbitrary wall positions and sampled cross-sections; not physical M1–M6 passage widths.'}}
    return result


def main():
    ap=argparse.ArgumentParser();mode=ap.add_mutually_exclusive_group(required=True)
    mode.add_argument('--write',action='store_true');mode.add_argument('--check',action='store_true')
    args=ap.parse_args();cfg=json.loads(CONFIG.read_text());rig=json.loads((ROOT/cfg['source_rig']).read_text())
    previous=json.loads((ROOT/cfg['source_t08_t09_results']).read_text())
    out=json.dumps(analyze(cfg,rig,previous),sort_keys=True,indent=2)+'\n'
    if args.write:
        RESULT.write_text(out);print('WROTE',RESULT)
    else:
        if not RESULT.exists() or RESULT.read_text()!=out:raise SystemExit('T10 input/results mismatch')
        print('ALCHUL T10 REPRODUCIBILITY PASS — assumption-driven mechanical checks only')
    j=json.loads(out)
    for k,v in j['candidates'].items():
        print(k,'brace:',v['force_checks']['supported_fixture']['equilibrium_feasible_assumed'],
              'opposing conceptual:',v['force_checks']['hypothetical_ring_clamp']['equilibrium_feasible_conditional'],
              'lean:',v['stepping']['required_com_lateral_shift_for_0p025_margin'],
              'corridor test width:',v['corner_clearance']['first_passing_width_IN_TEST_GRID'])

if __name__=='__main__':main()
