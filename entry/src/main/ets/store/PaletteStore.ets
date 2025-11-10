import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { promptAction } from '@kit.ArkUI';


export type HSL = { h:number; s:number; l:number }
export type GradStop = { offset:number; hex:string; easing?: 'linear'|'easeIn'|'easeOut'|'easeInOut' }


export class PaletteStore {
  @Observed currentHEX: string = '#5A8CFF'
  @Observed hsl: HSL = { h: 220, s: 0.8, l: 0.65 }
  @Observed currentSwatches: string[] = ['#5A8CFF', '#222222', '#FFFFFF']
  @Observed gradientStops: GradStop[] = [ { offset: 0, hex: '#5A8CFF' }, { offset: 1, hex: '#12D8A7' } ]


  constructor(){ AppStorage.setOrCreate('paletteStore', this) }


  setHSL(h:number,s:number,l:number){
    this.hsl = { h: clamp(h,0,360), s: clamp(s,0,1), l: clamp(l,0,1) }
    this.currentHEX = hslToHex(this.hsl)
    this.currentSwatches[0] = this.currentHEX
  }
  pushSwatch(hex:string){ if (!this.currentSwatches.includes(hex)) this.currentSwatches.unshift(hex); this.currentSwatches = this.currentSwatches.slice(0,8) }
  setGradientStops(stops:GradStop[]){ this.gradientStops = stops }


  exportTokens(ctx: common.UIAbilityContext){
    const tokens = {
      'color-primary': this.currentHEX,
      'gradient-1-start': this.gradientStops[0]?.hex ?? this.currentHEX,
      'gradient-1-end': this.gradientStops[this.gradientStops.length-1]?.hex ?? this.currentHEX
    }
    const css = toCSSVars(tokens)
    fileSaveText(ctx, 'tokens.css', css)
  }
}


// Provider at app root
@Component
export struct PaletteProvider {
  store: PaletteStore
  @BuilderParam content?: () => void
  build(){
    if (!AppStorage.has('paletteStore')) {
      AppStorage.setOrCreate('paletteStore', this.store)
      }
    this.content && this.content()
  }
}


export function usePalette(): PaletteStore {
  let s = AppStorage.get<PaletteStore>('paletteStore')
  if (!s) { s = new PaletteStore(); AppStorage.setOrCreate('paletteStore', s) }
  return s
}


function clamp(v:number, min:number, max:number){ return Math.max(min, Math.min(max, v)) }


function hslToHex(hsl:HSL): string {
  const {h,s,l} = hsl; const c=(1-Math.abs(2*l-1))*s; const x=c*(1-Math.abs((h/60)%2-1)); const m=l-c/2;
  let r=0,g=0,b=0; const hS=Math.floor(h/60)%6
  const map=[[c,x,0],[x,c,0],[0,c,x],[0,x,c],[x,0,c],[c,0,x]][hS]
  if (map){ r=map[0]; g=map[1]; b=map[2] }
  const R=Math.round((r+m)*255), G=Math.round((g+m)*255), B=Math.round((b+m)*255)
  return '#' + [R,G,B].map(v=>v.toString(16).padStart(2,'0')).join('').toUpperCase()
}


function toCSSVars(tokens: Record<string,string>): string {
  const lines = Object.entries(tokens).map(([k,v]) => ` --${k}: ${v};`)
  return `:root{\n${lines.join('\n')}\n}`
}


function fileSaveText(ctx: common.UIAbilityContext, name:string, content:string){
  try {
    const dir = ctx.filesDir
    const path = dir + '/' + name
    const fd = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE)
    fs.writeSync(fd.fd, content)
    fs.closeSync(fd)
    promptAction.showToast({ message: `已导出到 ${path}` })
  } catch (e) { console.error('save error', e) }
}