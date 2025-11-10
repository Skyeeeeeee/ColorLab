import { GradStop } from '../store/PaletteStore'


@Component
export struct GradientTimeline {
  stops: GradStop[] = []
  onStopsChange?: (stops:GradStop[])=>void


  @State private local: GradStop[] = []
  @State private barWidth: number = 300


  aboutToAppear(){ this.local = this.stops.length? this.stops.map(s=>({...s})) : [{offset:0,hex:'#5A8CFF'},{offset:1,hex:'#12D8A7'}] }


  build(){
    Column(){
      // preview
      Rect().width('100%').height(28).borderRadius(6)
        .linearGradient({ angle: 0, colors: this.local.map(s=>({ color: s.hex, offset: s.offset })) })
        .onSizeChange((w:number, _h:number)=>{ if (w>0) this.barWidth = w })


      // stops overlay (drag within measured width)
      Stack(){
        ForEach(this.local, (s, idx:number)=>{
          Column(){ Text('◆').fontSize(18).fontColor('#FFFFFF') }
          .position({ x: `${s.offset*100}%`, y: 2 })
          .gesture(PanGesture().onActionUpdate(e=>{
            const delta = e.offsetX / Math.max(this.barWidth, 1)
            this.local[idx].offset = clamp01(this.local[idx].offset + delta)
            this.onStopsChange?.(this.local)
          }))
          .onClick(()=>{
            const demo = ['#5A8CFF', '#FF7A00', '#12D8A7', '#FF4D8B']
            const next = demo[(demo.indexOf(this.local[idx].hex)+1+demo.length)%demo.length]
            this.local[idx].hex = next; this.onStopsChange?.(this.local)
          })
        }, (s)=> `${s.offset}-${s.hex}`)
      }.height(36).margin({ top:8 })


      Row(){
        Button('添加色标').onClick(()=>{ this.local.push({ offset: 0.5, hex: '#FFFFFF' }); this.onStopsChange?.(this.local) })
        Button('删除末尾').onClick(()=>{ if (this.local.length>2){ this.local.pop(); this.onStopsChange?.(this.local) } })
      }.justifyContent(FlexAlign.SpaceBetween).margin({ top:8 })
    }
    .padding(8).borderRadius(12).backgroundColor('#1B1B1B')
  }
}


function clamp01(v:number){ return Math.max(0, Math.min(1, v)) }