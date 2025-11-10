@Component
export struct ColorLoupe {
  onPick?: (hex: string) => void

  @State private boardWidth: number = 0
  @State private boardHeight: number = 0
  @State private pointerX: number = 0.45
  @State private pointerY: number = 0.35
  @State private previewHex: string = '#5A8CFF'

  private readonly swatches: string[] = ['#5A8CFF', '#FF7A00', '#12D8A7', '#FF4D8B', '#FFFFFF', '#000000']

  aboutToAppear() {
    this.updateColor(this.pointerX, this.pointerY)
  }

  build() {
    Column() {
      Text('图像取色 (模拟)')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })

      // Selected color preview
      Row() {
        Blank().height(56).layoutWeight(1).borderRadius(12).backgroundColor(this.previewHex)
        Column() {
          Text(this.previewHex).fontSize(14).fontColor('#CCCCCC')
          Text('点击或拖拽下方取色区域').fontSize(12).fontColor('#888888')
        }.margin({ left: 12 })
      }
      .padding(12)
      .backgroundColor('#1F1F1F')
      .borderRadius(16)

      // Synthetic color board
      Stack() {
        Rect()
          .width('100%')
          .height('100%')
          .borderRadius(12)
          .linearGradient({
            angle: 0,
            colors: [
              { color: '#FF0000', offset: 0 },
              { color: '#FFFF00', offset: 0.17 },
              { color: '#00FF00', offset: 0.33 },
              { color: '#00FFFF', offset: 0.5 },
              { color: '#0000FF', offset: 0.67 },
              { color: '#FF00FF', offset: 0.83 },
              { color: '#FF0000', offset: 1 }
            ]
          })
        Rect()
          .width('100%')
          .height('100%')
          .borderRadius(12)
          .linearGradient({ angle: 90, colors: [
            { color: '#FFFFFFFF', offset: 0 },
            { color: '#00FFFFFF', offset: 0.4 },
            { color: '#FF000000', offset: 1 }
          ] })
        Circle()
          .width(24)
          .height(24)
          .borderRadius(12)
          .border({ width: 2, color: '#FFFFFFAA' })
          .backgroundColor('#00000000')
          .position({
            x: `${this.pointerX * 100}%`,
            y: `${this.pointerY * 100}%`
          })
      }
      .height(180)
      .margin({ top: 16 })
      .backgroundColor('#121212')
      .borderRadius(16)
      .onSizeChange((w: number, h: number) => {
        if (w > 0) { this.boardWidth = w }
        if (h > 0) { this.boardHeight = h }
      })
      .onTouch(event => {
        if (!event.touches || event.touches.length === 0) {
          return
        }
        const point = event.touches[0]
        const xRatio = clamp01(point.x / Math.max(1, this.boardWidth))
        const yRatio = clamp01(point.y / Math.max(1, this.boardHeight))
        this.updateColor(xRatio, yRatio)
      })

      // Quick palette buttons for accessibility
      Row() {
        ForEach(this.swatches, (hex: string) => {
          Button(hex)
            .backgroundColor('#222222')
            .fontColor('#EEEEEE')
            .padding({ left: 12, right: 12 })
            .borderRadius(10)
            .onClick(() => this.updateColorFromHex(hex))
        }, (hex: string) => hex)
      }
      .margin({ top: 18 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(12)
    .borderRadius(18)
    .backgroundColor('#181818')
  }

  private updateColor(xRatio: number, yRatio: number) {
    this.pointerX = clamp01(xRatio)
    this.pointerY = clamp01(yRatio)
    const h = this.pointerX * 360
    const l = 0.15 + (1 - this.pointerY) * 0.7
    const s = 0.35 + (1 - this.pointerY) * 0.5
    this.previewHex = hslToHex({ h, s: clamp01(s), l: clamp01(l) })
    this.onPick?.(this.previewHex)
  }

  private updateColorFromHex(hex: string) {
    this.previewHex = normalizeHex(hex)
    this.onPick?.(this.previewHex)
  }
}

function clamp01(v: number): number {
  return Math.max(0, Math.min(1, v))
}

function normalizeHex(hex: string): string {
  const normalized = hex.startsWith('#') ? hex : `#${hex}`
  if (normalized.length === 4) {
    const r = normalized[1]
    const g = normalized[2]
    const b = normalized[3]
    return `#${r}${r}${g}${g}${b}${b}`.toUpperCase()
  }
  return normalized.toUpperCase()
}

type HSL = { h: number; s: number; l: number }

function hslToHex(hsl: HSL): string {
  const { h, s, l } = hsl
  const c = (1 - Math.abs(2 * l - 1)) * s
  const x = c * (1 - Math.abs(((h / 60) % 2) - 1))
  const m = l - c / 2
  const segment = Math.floor(h / 60) % 6
  const map: number[][] = [[c, x, 0], [x, c, 0], [0, c, x], [0, x, c], [x, 0, c], [c, 0, x]]
  const [r, g, b] = map[segment] ?? [0, 0, 0]
  const R = Math.round((r + m) * 255)
  const G = Math.round((g + m) * 255)
  const B = Math.round((b + m) * 255)
  return `#${R.toString(16).padStart(2, '0')}${G.toString(16).padStart(2, '0')}${B.toString(16).padStart(2, '0')}`.toUpperCase()
}
