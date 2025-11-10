import { GradStop } from '../store/PaletteStore'


@Component
export struct GradientTimeline {
  stops: GradStop[] = []
  onStopsChange?: (stops:GradStop[])=>void


  @State private local: GradStop[] = []


  aboutToAppear(){ this.local = this.stops.length? this.stops.map(s=>({...s})) : [{offset:0,hex:'#5A8CFF'},{offset:1,hex:'#12D8A7'}] }


  build(){
    Column(){
      // Preview bar
      Rect().width('100%').height(28).borderRadius(6)
        .linearGradient({ angle: 0, colors: this.local.map(s=>({ color: s.hex, offset: s.offset })) })


      // Draggable stops area
      Stack(){
        ForEach(this.local, (s, idx:number)=>{
          Column(){
            Text('◆').fontSize(18).fontColor('#FFFFFF')
          }
          .position({ x: `${s.offset*100}%`, y: 2 })
          .gesture(PanGesture().onActionUpdate(e=>{
            const w = 300; // logical width estimate; for real use measure the container width
            const delta = e.offsetX / w
            this.local[idx].offset = Math.max(0, Math.min(1, this.local[idx].offset + delta))
            this.onStopsChange?.(this.local)
          }))
          .onClick(()=>{
            // cycle color quick demo
            const demo = ['#5A8CFF', '#FF7A00', '#12D8A7', '#FF4D8B']
            const next = demo[(demo.indexOf(this.local[idx].hex)+1+demo.length)%demo.length]
            this.local[idx].hex = next; this.onStopsChange?.(this.local)
          })
        }, (s)=> `${s.offset}-${s.hex}`)
      }.height(36).margin({ top:8 })


      Row(){
        Button('添加色标').onClick(()=>{
          this.local.push({ offset: 0.5, hex: '#FFFFFF' }); this.onStopsChange?.(this.local)
        })
        Button('删除末尾').onClick(()=>{
          if (this.local.length>2){ this.local.pop(); this.onStopsChange?.(this.local) }
        })
      }.justifyContent(FlexAlign.SpaceBetween).margin({ top:8 })
    }
    .padding(8).borderRadius(12).backgroundColor('#1B1B1B')
  }
}