import { AppPage, ServerItem } from '../models/AppModels';

export interface BottomTabItem {
  page: AppPage
  label: string
}

@Component
export struct PageHeader {
  title: string = ''
  subtitle: string = ''

  build() {
    Column({ space: 6 }) {
      Text(this.title)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')
      if (this.subtitle && this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(13)
          .fontColor('#d1d5db')
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}

@Component
export struct SectionCard {
  title: string = ''

  @Builder contentBuilder() {}

  build() {
    Column({ space: 14 }) {
      if (this.title && this.title.length > 0) {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')
      }
      this.contentBuilder()
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#ffffff')
    .borderRadius(18)
  }
}

@Component
export struct ActionButton {
  text: string = ''
  type: 'primary' | 'secondary' | 'danger' = 'primary'
  onPress: () => void = () => {}

  build() {
    Button(this.text)
      .type(ButtonType.Capsule)
      .width('100%')
      .height(44)
      .fontColor(this.type === 'secondary' ? '#111827' : '#ffffff')
      .backgroundColor(this.type === 'primary' ? '#2563eb' : this.type === 'danger' ? '#dc2626' : '#e5e7eb')
      .onClick(() => this.onPress())
  }
}

@Component
export struct FieldLabel {
  text: string = ''

  build() {
    Text(this.text)
      .fontSize(13)
      .fontColor('#6b7280')
      .width('100%')
  }
}

@Component
export struct ServerListCard {
  item: ServerItem = { id: '', name: '', host: '', port: 22, username: '' }
  onEdit: (server: ServerItem) => void = () => {}
  onTerminal: (server: ServerItem) => void = () => {}
  onSftp: (server: ServerItem) => void = () => {}

  build() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.item.name)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          Text(`${this.item.username}@${this.item.host}:${this.item.port}`)
            .fontSize(13)
            .fontColor('#6b7280')
          if (this.item.remark && this.item.remark.length > 0) {
            Text(this.item.remark)
              .fontSize(12)
              .fontColor('#9ca3af')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      Row({ space: 10 }) {
        Button('终端')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor('#111827')
          .onClick(() => this.onTerminal(this.item))
        Button('文件')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor('#059669')
          .onClick(() => this.onSftp(this.item))
        Button('编辑')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor('#2563eb')
          .onClick(() => this.onEdit(this.item))
      }
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#ffffff')
    .borderRadius(18)
  }
}

@Component
export struct BottomTabs {
  currentPage: AppPage = AppPage.Home
  tabs: BottomTabItem[] = []
  onChange: (page: AppPage) => void = () => {}

  build() {
    Row() {
      ForEach(this.tabs, (item: BottomTabItem) => {
        Column({ space: 4 }) {
          Text(item.label)
            .fontSize(13)
            .fontWeight(this.currentPage === item.page ? FontWeight.Bold : FontWeight.Regular)
            .fontColor(this.currentPage === item.page ? '#2563eb' : '#6b7280')
        }
        .layoutWeight(1)
        .padding({ top: 12, bottom: 12 })
        .onClick(() => this.onChange(item.page))
      })
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .borderRadius({ topLeft: 20, topRight: 20 })
  }
}
