#!/usr/bin/env python3
"""Generate reproducible *computed* T08/T09 concept-constraint charts.

Optional contributor visualization tool (requires matplotlib). Never pass these
plots off as measured anatomy or actual Godot screenshots.
"""
from pathlib import Path
import argparse
import json
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, FancyArrowPatch, Circle

DATA = Path(__file__).resolve().parents[1] / 'data/m11_t08_t09_results.json'
COLORS = {'H-A':'#a65f3b','H-B':'#336b71'}
INK='#233235'; BG='#f4f0e6'; LIGHT='#dfd6c5'; GRID='#b9c1bb'


def theme(ax):
    ax.set_facecolor(BG)
    for s in ax.spines.values():s.set_color('#91a099')
    ax.grid(alpha=.22,linewidth=.7,color=GRID)
    ax.tick_params(labelsize=11,colors=INK)


def save_t8(data,out):
    fig,axes=plt.subplots(1,2,figsize=(15.8,7.3),constrained_layout=False)
    fig.subplots_adjust(left=.065,right=.985,top=.85,bottom=.13,wspace=.23)
    fig.set_facecolor(BG)
    for ax,key in zip(axes,('H-A','H-B')):
        theme(ax)
        src=data['t08'][key]
        box=src['cases']['two_feet_neutral']['support_box_xmin_xmax_zmin_zmax']
        one=src['cases']['right_foot_only']['support_box_xmin_xmax_zmin_zmax']
        ax.add_patch(Rectangle((box[0],box[2]),box[1]-box[0],box[3]-box[2],
                 linewidth=2.6,facecolor='#dce4d8',edgecolor=COLORS[key],alpha=.80,label='Two-foot contact envelope'))
        ax.add_patch(Rectangle((one[0],one[2]),one[1]-one[0],one[3]-one[2],
                 linewidth=1.8,facecolor='#a0b8b1',edgecolor=INK,linestyle='--',alpha=.65,label='Right foot alone'))
        for scenario,marker,dx,dz in [('two_feet_neutral','o',0.02,0.024),('two_feet_forward_reach','^',0.02,-0.028),('two_feet_with_cargo_proxy','D',0.02,0.065)]:
            x,z=src['cases'][scenario]['projected_com_xz']
            ax.scatter([x],[z],s=170,marker=marker,edgecolor=INK,linewidth=1.3,zorder=10,color=COLORS[key])
            short={'two_feet_neutral':'Neutral COM','two_feet_forward_reach':'Forward proxy','two_feet_with_cargo_proxy':'Cargo proxy'}[scenario]
            ax.annotate(short,(x,z),xytext=(x+dx,z+dz),fontsize=9.6,color=INK)
        ax.axhline(0,color=INK,lw=.9,alpha=.35)
        ax.axvline(0,color=INK,lw=.9,alpha=.25)
        ax.set_xlim(-.14,.91);ax.set_ylim(-.60,.60)
        ax.set_aspect('equal',adjustable='box');ax.set_xlabel('Normalized anterior X  •  NOT meters',fontsize=12,color=INK)
        ax.set_ylabel('Normalized lateral Z  •  NOT meters',fontsize=12,color=INK)
        mass=src['region_mass_fractions']
        subtitle='Long-tail candidate' if key=='H-A' else 'Compact-tail candidate'
        ax.set_title(f'{key}  /  {subtitle}',fontsize=19,fontweight='bold',color=INK,pad=18)
        neutral=src['cases']['two_feet_neutral']['signed_margin']
        only=src['cases']['right_foot_only']['signed_margin']
        stable=src['sensitivity_neutral']['fraction_positive']
        ax.text(.03,.03,f'Two-foot signed margin   {neutral:+.3f}\nUnshifted one-foot margin   {only:+.3f}\nMass jitter in-box fraction   {stable:.1%}',
                transform=ax.transAxes,va='bottom',ha='left',fontsize=11.5,color=INK,
                bbox={'boxstyle':'round,pad=.6','facecolor':'#fffdf7','edgecolor':LIGHT})
        ax.text(.97,.97,f'Assumed tail mass: {mass["tail"]:.0%}',transform=ax.transAxes,va='top',ha='right',fontsize=11,color=INK)
    fig.suptitle('ALCHUL M11  |  T08 — CENTER-OF-MASS PROXY & SUPPORT ENVELOPE',fontsize=20,fontweight='bold',color=INK,y=.98)
    fig.text(.5,.02,'All geometry, support patches, segment weights and cargo are invented engineering inputs. Static COM-in-box ≠ dynamic balance, gait or safety.',
             ha='center',fontsize=10.8,color='#7b3731')
    fig.savefig(out,dpi=175,bbox_inches='tight',facecolor=BG)
    plt.close(fig)


def save_t9(data,out):
    fig,axes=plt.subplots(1,2,figsize=(15.8,7.3),constrained_layout=False)
    fig.subplots_adjust(left=.065,right=.985,top=.85,bottom=.13,wspace=.23)
    fig.set_facecolor(BG)
    for ax,key in zip(axes,('H-A','H-B')):
        theme(ax)
        near=data['t09'][key]['near'];far=data['t09'][key]['far']
        for i,digit in enumerate(('I','II','III')):
            c=near['digits'][digit];t=c['target'];p=c['predicted_tip']
            ax.scatter([t[0]],[t[2]],s=240,facecolor='none',edgecolor=COLORS[key],linewidth=2.3,zorder=5)
            ax.add_patch(Circle((t[0],t[2]),near['tolerance'],fill=False,linestyle=':',linewidth=1.5,color=COLORS[key],alpha=.75))
            ax.scatter([p[0]],[p[2]],s=130,marker=['o','^','s'][i],color=COLORS[key],edgecolor=INK,zorder=7)
            ax.plot([p[0],t[0]],[p[2],t[2]],linewidth=1.5,color='#5b756c')
            ax.annotate(f'Digit {digit}',(p[0],p[2]),xytext=(10,9),textcoords='offset points',fontsize=10,color=INK)
            far_t=far['digits'][digit]['target'];ax.scatter([far_t[0]],[far_t[2]],s=135,marker='x',linewidths=2,color='#bf6a5e',zorder=6)
        ax.set_aspect('auto');ax.set_xlim(1.52,3.45);ax.set_ylim(.02,.72)
        ax.set_xlabel('Normalized anterior X   •   NOT meters',fontsize=12,color=INK)
        ax.set_ylabel('Normalized lateral Z   •   NOT meters',fontsize=12,color=INK)
        ax.set_title(f'{key}  /  three discrete fingertips',fontsize=19,color=INK,pad=16,fontweight='bold')
        ax.text(.03,.035,f'Near fixture max error {near["maximum_contact_error"]:.3f}  → {near["contact_count"]}/3 in tolerance\n'+
                f'Far fixture max error {far["maximum_contact_error"]:.3f}  → {far["contact_count"]}/3 in tolerance\n'+
                'Circles = assumed tolerance, X = distant fixture',transform=ax.transAxes,ha='left',va='bottom',fontsize=10.7,color=INK,
                bbox={'boxstyle':'round,pad=.5','facecolor':'#fffdf7','edgecolor':LIGHT})
    fig.suptitle('ALCHUL M11  |  T09 — THREE-DIGIT CONTACT PROXIMITY TEST',fontsize=20,fontweight='bold',color=INK,y=.98)
    fig.text(.5,.02,'X-Z projection (vertical Y not drawn; errors use full 3D distance). Assumed fixtures and sampled poses cannot establish forces, closure or manipulation.',
             ha='center',fontsize=10.8,color='#7b3731')
    fig.savefig(out,dpi=175,bbox_inches='tight',facecolor=BG)
    plt.close(fig)


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--out',required=True)
    args=parser.parse_args();out=Path(args.out);out.mkdir(parents=True,exist_ok=True)
    data=json.loads(DATA.read_text('utf-8'))
    save_t8(data,out/'ALCHUL_T08_SUPPORT_COM.png')
    save_t9(data,out/'ALCHUL_T09_THREE_DIGIT_CONTACTS.png')
    print('Rendered T08 and T09 numerical illustrations — not Godot captures')
if __name__=='__main__': main()
