#!/usr/bin/env python3
"""Render measured *computational* T10 geometry, not a Godot screenshot."""
import json,math,sys
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle,Circle,PathPatch,Polygon
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
import m11_t10_mechanics as m
RES=ROOT/'data/m11_t10_force_locomotion_results.json';CFG=ROOT/'data/m11_t10_force_locomotion_config.json'
RIG=ROOT/'data/m11_t07_skeletal_reference.json'
OUT=Path(sys.argv[1]) if len(sys.argv)>1 else ROOT.parent.parent/'renders'
OUT.mkdir(parents=True,exist_ok=True)
res=json.loads(RES.read_text());cfg=json.loads(CFG.read_text());rig=json.loads(RIG.read_text())
COL={'H-A':'#af6749','H-B':'#2b6572'}
BG='#f8f6f0';INK='#243238';WARN='#a24b3d';GOOD='#37775d';LIGHT='#e5e2d9';GREY='#747c7b'
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,'axes.edgecolor':'#bbbdb6','text.color':INK,'axes.labelcolor':INK,'xtick.color':'#56605e','ytick.color':'#56605e','savefig.facecolor':BG})

def figure(title,subtitle):
    fig=plt.figure(figsize=(15.5,8.3),facecolor=BG)
    fig.text(.04,.947,title,fontsize=22,fontweight='bold',color=INK)
    fig.text(.04,.905,subtitle,fontsize=11,color='#586864')
    return fig

def force_diagram():
    fig=figure('ALCHUL M11 / MECHANICAL CONTACT FEASIBILITY','T9+ force extension  •  normalized body-weight forces; 2D quasi-static equilibrium  •  NOT verified biological grip')
    ax1=fig.add_axes([.055,.20,.41,.63]);ax2=fig.add_axes([.535,.20,.41,.63])
    data=res['candidates']['H-A']['force_checks']
    q=data['supported_fixture'];ring=data['hypothetical_ring_clamp']
    for ax in (ax1,ax2):
        ax.set_facecolor('#fffefa');ax.axis('off');ax.set_aspect('equal')
    ax1.set_xlim(-.68,.75);ax1.set_ylim(-.60,.57)
    ax1.set_title('A  |  Backed stone fixture — conditional PASS',fontsize=14,fontweight='bold',loc='left',pad=16,color=GOOD)
    ax1.add_patch(Rectangle((-.15,-.20),.30,.40,facecolor='#d1c6af',edgecolor='#6c6459',linewidth=2,zorder=2))
    ax1.plot([.15,.15],[-.40,.42],color=GREY,linewidth=7,solid_capstyle='round',zorder=1)
    ax1.text(.27,.38,'Fixed support',ha='left',fontsize=10,color='#526466')
    for i,c in enumerate(q['fingers']):
        x,y=c['position']; y=y*.9
        ax1.plot([-.42,x], [y,y],color=COL['H-A'],lw=8,solid_capstyle='round')
        ax1.scatter([x],[y],s=130,color=COL['H-A'],edgecolor=INK,zorder=5)
        ax1.arrow(x,y,0.19,.06,head_width=.035,head_length=.04,color=GOOD,length_includes_head=True,zorder=9)
        ax1.text(-.57,y+.05,('I','II','III')[i],fontsize=11,fontweight='bold')
    ax1.arrow(0,0,0,-.30,head_width=.05,head_length=.06,color=WARN,length_includes_head=True,lw=2,zorder=10)
    ax1.text(.04,-.44,'External load = 0.32 BW',fontsize=10,color=WARN)
    ax1.text(-.62,-.55,'Normal per digit 0.107 BW; wall + friction required',fontsize=10,color=INK)
    ax2.set_xlim(-.68,.75);ax2.set_ylim(-.60,.57)
    ax2.set_title('B  |  Opposed radial contacts — HYPOTHETICAL',fontsize=14,fontweight='bold',loc='left',pad=16,color=COL['H-B'])
    R=cfg['grip']['hypothetical_opposing_ring']['radius_normalized']
    ax2.add_patch(Circle((0,0),R,edgecolor='#685e50',facecolor='#d8cab4',lw=2))
    for i,c in enumerate(ring['contacts']):
        x,y=c['position']
        ax2.scatter([x],[y],s=140,facecolor=COL['H-B'],edgecolor=INK,zorder=5)
        f=c['force']; a=.45
        ax2.arrow(x,y,a*f[0],a*f[1],head_width=.024,head_length=.034,color=GOOD,length_includes_head=True,zorder=6)
        ax2.text(x*1.95,y*1.95,('I','II','III')[i],fontsize=11,fontweight='bold',ha='center')
    ax2.arrow(.12,.08,0,-.32,head_width=.05,head_length=.06,color=WARN,length_includes_head=True)
    ax2.text(-.60,-.34,'Not attained by the T07/T09 hand geometry',fontsize=11,color=WARN)
    ax2.text(-.60,-.50,'A 2D single-load solution is NOT full force closure',fontsize=10,color=INK)
    fig.text(.05,.11,'PASSED SOFTWARE: static Fx/Fy/torque balance, Coulomb friction inequalities, assumed joint-load ceilings. Negative tests: no wall, low friction, weak digit.',fontsize=11,color=INK)
    fig.text(.05,.062,'UNCERTAIN BIOLOGY: no measured tendon leverage, normal direction, pad friction, muscle stress, mass in kilograms, or proof of free-object grasp.',fontsize=10.8,color=WARN)
    path=OUT/'ALCHUL_T09_FORCE_BALANCE.png';fig.savefig(path,dpi=160,bbox_inches='tight');plt.close(fig);print(path)

def draw_corridor(ax,width):
    h=width/2
    # Actual union L floor: incoming west reach + outgoing north reach, clipped with x[-5,5],z[-5,5]
    ax.add_patch(Rectangle((-5,-h),5+h,2*h,fc='#e5e4dc',ec='#a9aaa3',lw=1.3,zorder=0))
    ax.add_patch(Rectangle((-h,-h),2*h,5+h,fc='#e5e4dc',ec='#a9aaa3',lw=1.3,zorder=1))
    # Walls visible as dashed thin lines: incoming side & outgoing side outside core overlap
    ax.plot([-5,-h],[-h,-h],color='#888c85',lw=2)
    ax.plot([-5,-h],[h,h],color='#888c85',lw=2)
    ax.plot([-h,-h],[h,5],color='#888c85',lw=2)
    ax.plot([h,h],[h,5],color='#888c85',lw=2)
    ax.grid(alpha=.15)

def body_draw(ax,points,pose,color,alpha=1,highlight=False):
    x,z,th=pose
    tail=[points[f'caudal_0{i}'][0] for i in range(4,0,-1)]+[0]
    front=[0,points['thorax'][0],points['neck_02'][0],points['skull'][0]]
    centerline=[m.rotate_translate((u,0),pose) for u in tail+front]
    ax.plot([t[0] for t in centerline],[t[1] for t in centerline],color=color,lw=5,alpha=alpha,solid_capstyle='round',zorder=7)
    for side in (-1,1):
        zz=points[f'metatarsus_{"L" if side<0 else "R"}'][2]
        p=m.rotate_translate((points['metatarsus_R'][0],zz),pose)
        ax.scatter([p[0]],[p[1]],marker='o',color=color,s=75,alpha=alpha,edgecolor='#263338',zorder=8)
    ax.scatter([x],[z],marker='o',s=90,color='#222c30',zorder=11)
    if highlight:
        stations=m.key_points(points,cfg['clearance'])
        sample=[m.rotate_translate(p,pose) for p in stations]
        for px,pz in sample:
            ok=m.in_L_corridor(px,pz,2.8)
            ax.scatter([px],[pz],s=24,facecolor=GOOD if ok else WARN,edgecolor='white',lw=.4,zorder=12)

def clearance_diagram():
    fig=figure('ALCHUL M11 / T10 — CORRIDOR TURN SWEEP','Foot-contact and rigid-tail spatial envelopes  •  same path and headings  •  normalized unmeasured corridors')
    poses=m.pose_samples(cfg['clearance']['turn_radius_normalized'],cfg['clearance']['samples_straight_per_leg'],cfg['clearance']['samples_turn'])
    for i,key in enumerate(('H-A','H-B')):
        ax=fig.add_axes([.05+i*.48,.23,.44,.60]);ax.set_facecolor('#fffefa')
        width=2.8;draw_corridor(ax,width)
        xy=[(x,z) for x,z,h in poses]
        ax.plot([p[0] for p in xy],[p[1] for p in xy],ls=':',lw=1.5,color='#8a928c')
        p=m.anchors(next(b for b in rig['bodies'] if b['id']==key))
        for j in [7,38,65,85]:
            body_draw(ax,p,poses[j],COL[key],alpha=.15 if j!=65 else .90,highlight=j==65)
        ax.set_xlim(-4.6,3.5);ax.set_ylim(-4.0,4.1);ax.set_aspect('equal')
        rr=res['candidates'][key]['corner_clearance']
        ok=next(x for x in rr['width_results'] if x['corridor_width']==width)
        title=f'{key}  •  {"PASS" if ok["clearance_pass"] else "FAIL"} at width 2.8'
        ax.set_title(title,loc='left',fontsize=16,fontweight='bold',color=GOOD if ok['clearance_pass'] else WARN,pad=13)
        ax.set_xlabel('normalized X, not meters');ax.set_ylabel('normalized Z, not meters')
        ax.text(.015,.02,f'First passing sampled width: {rr["first_passing_width_IN_TEST_GRID"]:.1f}\nViolating path samples at 2.8: {ok["violating_samples"]} / {ok["total_samples"]}',
            transform=ax.transAxes,fontsize=10,va='bottom',color=INK,bbox={'facecolor':'white','edgecolor':LIGHT,'pad':8})
    fig.text(.055,.13,'Red samples indicate sections outside the 2.8-wide test corridor. Tail/body treated as rigid; flexible tail control, collision response, dynamic balance are not modeled.',fontsize=10.5,color=WARN)
    fig.text(.055,.09,'The Braided Reach\'s actual passage widths have NOT been measured or imported into this study. These numbers must not define architecture canon.',fontsize=10.8,color=INK)
    path=OUT/'ALCHUL_T10_TURN_CLEARANCE.png';fig.savefig(path,dpi=155,bbox_inches='tight');plt.close(fig);print(path)

def step_diagram():
    fig=figure('ALCHUL M11 / T10 — SINGLE-STANCE SUPPORT CHECK','Projected COM, assumed right-foot support, inferred body shift required for margin 0.025; no dynamic gait or measured balance')
    for i,key in enumerate(('H-A','H-B')):
        ax=fig.add_axes([.06+i*.47,.19,.40,.63]);ax.set_facecolor('#fffefa')
        r=res['candidates'][key]['stepping'];p=m.anchors(next(b for b in rig['bodies'] if b['id']==key));f=p['metatarsus_R'];half=cfg['locomotion']['foot_half_width'];box=m.footprint_limits((f[0],f[2]),abs(f[2]),half)
        rect=Rectangle((box[0],box[2]),box[1]-box[0],box[3]-box[2],fc='#e2eacf',ec=COL[key],lw=2.6)
        ax.add_patch(rect)
        x=json.loads((ROOT/'data/m11_t08_t09_results.json').read_text())['t08'][key]['cases']['two_feet_neutral']['com_xyz'][0]
        ax.scatter([x],[0],s=125,color=WARN,marker='x',linewidths=3,label='Unshifted COM',zorder=8)
        z=r['required_com_lateral_shift_for_0p025_margin'];ax.scatter([x],[z],s=150,color=GOOD,marker='o',edgecolor=INK,label='Assumed adjusted COM',zorder=8)
        ax.annotate('',xy=(x,z-.015),xytext=(x,.02),arrowprops=dict(arrowstyle='-|>',lw=2,color=INK))
        ax.axhline(0,lw=.8,color='#878b8a',ls='--');ax.set_xlim(-.25,.9);ax.set_ylim(-.4,.8);ax.set_aspect('equal');ax.grid(alpha=.15)
        ax.set_title(key+'  /  right-foot transfer',loc='left',fontsize=16,fontweight='bold',color=COL[key],pad=12)
        ax.text(.02,.97,f'Required shift: {z:.3f}\nEquivalent rigid lean: {r["implied_body_lean_deg_if_rigid"]:.1f}°\nNormalized roll moment: {r["required_stance_leg_roll_moment_proxy"]:.3f}',
                transform=ax.transAxes,va='top',ha='left',fontsize=10.7,bbox={'facecolor':'white','edgecolor':LIGHT,'pad':6})
        ax.legend(loc='lower right',fontsize=10)
        ax.set_xlabel('Normalized anterior X');ax.set_ylabel('Normalized lateral Z')
    fig.text(.055,.105,'Within model: both right-foot phases pass only after the assumed shift. Tested traction: wet stone PASS (μ=.34); slippery mud FAIL (μ=.055).',fontsize=11,color=INK)
    fig.text(.055,.067,'This is a quasi-static center-of-mass placement requirement, not evidence that joints, muscles or the nervous system can produce it.',fontsize=11,color=WARN)
    path=OUT/'ALCHUL_T10_STEP_SUPPORT.png';fig.savefig(path,dpi=160,bbox_inches='tight');plt.close(fig);print(path)

def turn_gif():
    poses=m.pose_samples(cfg['clearance']['turn_radius_normalized'],cfg['clearance']['samples_straight_per_leg'],cfg['clearance']['samples_turn'])
    frames=[]
    for idx in np.linspace(5,len(poses)-5,17,dtype=int):
        fig,axes=plt.subplots(1,2,figsize=(11.5,5.5),facecolor=BG)
        for ax,key in zip(axes,('H-A','H-B')):
            ax.set_facecolor('#fffefa');draw_corridor(ax,2.8)
            p=m.anchors(next(b for b in rig['bodies'] if b['id']==key))
            body_draw(ax,p,poses[int(idx)],COL[key],highlight=True)
            ax.set_xlim(-4.2,3.5);ax.set_ylim(-3.7,4.0);ax.set_aspect('equal');ax.axis('off')
            ax.set_title(f'{key} / {"LONG" if key=="H-A" else "COMPACT"} TAIL',fontsize=14,color=COL[key],fontweight='bold')
        fig.suptitle('T10   •   Rigid-tail corner study   •   corridor width 2.8',fontsize=16,fontweight='bold',color=INK)
        fig.text(.5,.025,'RED = outside assumed corridor  •  hypothetical path, not captured animal movement',ha='center',color=WARN,fontsize=10)
        import io
        imdata=io.BytesIO();fig.savefig(imdata,dpi=90,facecolor=BG,bbox_inches='tight');plt.close(fig)
        imdata.seek(0);frames.append(Image.open(imdata).convert('RGB').resize((1050,500)))
    path=OUT/'ALCHUL_T10_TURN_SEQUENCE.gif';frames[0].save(path,save_all=True,append_images=frames[1:]+[frames[0]],duration=145,loop=0,optimize=True)
    print(path)

if __name__=='__main__':force_diagram();clearance_diagram();step_diagram();turn_gif()
