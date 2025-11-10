import { PaletteStore, PaletteProvider } from '../store/PaletteStore';
import { StagePage } from './StagePage';


@Entry
@Component
struct AppRoot {
  private store: PaletteStore = new PaletteStore();
  build() {
    PaletteProvider({ store: this.store }) {
      Navigation() {
        NavDestination() {
          Tabs() {
            TabContent() { StagePage() }
            .tabBar({ icon: $r('app.media.ic_color'), text: '调色' })
            TabContent() { GradientStudioPage() }
            .tabBar({ icon: $r('app.media.ic_gradient'), text: '渐变' })
            TabContent() { PreviewWallPage() }
            .tabBar({ icon: $r('app.media.ic_preview'), text: '预览' })
          }
          .barMode(BarMode.Fixed)
          .height('100%')
        }
      }
    }
  }
}


@Component
export struct GradientStudioPage { build(){ Column(){ Text('Gradient Studio (stub)') }.justifyContent(FlexAlign.Center).height('100%') }}
@Component
export struct PreviewWallPage { build(){ Column(){ Text('Preview Wall (stub)') }.justifyContent(FlexAlign.Center).height('100%') }}
