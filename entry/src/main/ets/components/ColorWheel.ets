import { HSL } from '../store/PaletteStore'


@Component
export struct ColorWheel {
  size: string | number = '100%'
  value: HSL ={ h: 200, s: 0.6, l: 0.55 }
  onChange?: (h:number,s:number,l:number)=>void


  @State private hue: number = this.value.h
  @State private sat: number = this.value.s
  @State private light: number = this.value.l


  aboutToAppear(){ this.syncFromProp() }
  aboutToRender(){ this.syncFromProp() }
  private syncFromProp(){ this.hue = this.value.h; this.sat = this.value.s; this.light = this.value.l }


  build(){
    Stack() {
      Rect()
        .width('100%')
        .height('100%')
        .borderRadius(999)
        .linearGradient({ angle: 0, colors: [
          { color: '#FF0000', offset: 0 }, { color: '#00FF00', offset: 0.33 }, { color: '#0000FF', offset: 0.66 }, { color: '#FF0000', offset: 1 }
        ]})
      Text(`${Math.round(this.hue)}° S:${Math.round(this.sat*100)} L:${Math.round(this.light*100)}`)
        .fontSize(14).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
    }
    .width(this.size).aspectRatio(1)
    .clip(true)
    .backgroundColor(hslToHex({ h: this.hue, s: this.sat, l: this.light }))
    .gesture(
      GestureGroup(GestureMode.Parallel)
        .addGesture(RotationGesture().onActionUpdate(e=>{ this.hue = (this.hue + e.angle * 180/Math.PI + 360) % 360; this.onChange?.(this.hue, this.sat, this.light) }))
        .addGesture(PinchGesture().onActionUpdate(e=>{ const next = Math.max(0, Math.min(1, this.sat * e.scale)); if (Math.abs(next - this.sat) > 0.001) { this.sat = next; this.onChange?.(this.hue, this.sat, this.light) } }))
        .addGesture(PanGesture().onActionUpdate(e=>{ const next = Math.max(0, Math.min(1, this.light - e.offsetY/300)); if (Math.abs(next - this.light) > 0.001) { this.light = next; this.onChange?.(this.hue, this.sat, this.light) } }))
    )
  }
}


function hslToHex(hsl:HSL): string {
  const h = hsl.h;
  const s = hsl.s;
  const l = hsl.l;
  const c=(1-Math.abs(2*l-1))*s; const x=c*(1-Math.abs((h/60)%2-1)); const m=l-c/2;
  let r=0,g=0,b=0; const hS=Math.floor(h/60)%6
  const map=[[c,x,0],[x,c,0],[0,c,x],[0,x,c],[x,0,c],[c,0,x]][hS]
  if (map){ r=map[0]; g=map[1]; b=map[2] }
  const R=Math.round((r+m)*255), G=Math.round((g+m)*255), B=Math.round((b+m)*255)
  return '#' + [R,G,B].map(v=>v.toString(16).padStart(2,'0')).join('').toUpperCase()
}