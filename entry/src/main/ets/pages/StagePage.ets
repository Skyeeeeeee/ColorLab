import { usePalette } from '../store/PaletteStore';
import { ColorWheel } from '../components/ColorWheel';
import { ColorLoupe } from '../components/ColorLoupe';
import { GradientTimeline } from '../components/GradientTimeline';


@Component
export struct StagePage {
  @State private widthPx: number = 0
  palette = usePalette();

  build(){

    Column(){
      // swatches
      Row(){
        ForEach(this.palette.currentSwatches, (hex: string) => {
          Blank().width(0).height(36).layoutWeight(1).backgroundColor(hex).borderRadius(8).margin(4)
        }, (hex: string)=>hex)
      }.padding(12)


      // color wheel
      ColorWheel({ value: this.palette.hsl, onChange: (h, s, l): void => this.palette.setHSL(h, s, l) })
        .margin({ left: 12, right: 12, bottom: 6 })
        .height('38%')


      // gradient timeline
      GradientTimeline({
        stops: this.palette.gradientStops,
        onStopsChange: (stops): void => this.palette.setGradientStops(stops)
      })
        .margin({ left:12, right:12, top:6, bottom:6 })


      // image color loupe
      ColorLoupe({ onPick: (hex: string): void => this.palette.pushSwatch(hex) })
        .height('26%').margin(12)


      Row(){
        Button('导出 Tokens').onClick(()=> this.palette.exportTokens())
      }.justifyContent(FlexAlign.End).padding(12)
    }
    .width('100%').height('100%')
  }
}