import { AppPage, ServerItem } from '../models/AppModels';

export class BottomTabItem {
  page: AppPage = AppPage.Home
  label: string = ''
  icon: string = ''
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
      if (this.subtitle.length > 0) {
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

  build() {
    Column({ space: 14 }) {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')
      }
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
  type: string = 'primary'
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
  item: ServerItem = new ServerItem()
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
          Text(this.item.username + '@' + this.item.host + ':' + this.item.port)
            .fontSize(13)
            .fontColor('#6b7280')
          if (this.item.remark.length > 0) {
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
          if (item.icon.length > 0) {
            Text(item.icon)
              .fontSize(16)
              .fontColor(this.currentPage === item.page ? '#2563eb' : '#9ca3af')
          }
          Text(item.label)
            .fontSize(12)
            .fontWeight(this.currentPage === item.page ? FontWeight.Medium : FontWeight.Regular)
            .fontColor(this.currentPage === item.page ? '#2563eb' : '#6b7280')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 10, bottom: 10 })
        .onClick(() => this.onChange(item.page))
      }, (item: BottomTabItem) => item.label)
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .border({ width: { top: 1 }, color: '#e5e7eb' })
  }
}
