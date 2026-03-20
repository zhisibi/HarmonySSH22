import {
  AppPage,
  ServerItem,
  SftpNode,
  TerminalLine,
  TerminalLineType,
  UserSession,
  cloneServerItem
} from '../models/AppModels';
import { MockAuthService, MockServerService, MockSftpService, MockTerminalService } from '../services/MockServices';
import { ActionButton, BottomTabs, BottomTabItem, PageHeader, ServerListCard, FieldLabel } from '../components/Common';

@Entry
@Component
struct Index {
  @State currentPage: AppPage = AppPage.Login
  @State session: UserSession = MockAuthService.getSession()
  @State backendUrl: string = MockAuthService.getDefaultBackendUrl()
  @State username: string = 'admin'
  @State password: string = '123456'

  @State servers: ServerItem[] = MockServerService.list()
  @State editingServer: ServerItem = MockServerService.createEmpty()
  @State selectedServer: ServerItem | null = null

  @State terminalInput: string = 'ls'
  @State terminalLines: TerminalLine[] = []

  @State currentSftpPath: string = '/'
  @State sftpList: SftpNode[] = MockSftpService.list('/')

  private bottomTabs: BottomTabItem[] = this.createBottomTabs()

  private createBottomTabs(): BottomTabItem[] {
    const homeTab: BottomTabItem = new BottomTabItem()
    homeTab.page = AppPage.Home
    homeTab.label = '首页'

    const settingsTab: BottomTabItem = new BottomTabItem()
    settingsTab.page = AppPage.Settings
    settingsTab.label = '设置'

    return [homeTab, settingsTab]
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          this.buildCurrentPage()
        }
        .padding({ left: 16, right: 16, top: 20, bottom: 20 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      if (this.currentPage !== AppPage.Login) {
        BottomTabs({
          currentPage: this.currentPage === AppPage.Settings ? AppPage.Settings : AppPage.Home,
          tabs: this.bottomTabs,
          onChange: (page: AppPage) => {
            this.currentPage = page
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f3f4f6')
  }

  @Builder
  private buildCard(title: string, content: string = '') {
    Column({ space: 12 }) {
      if (title.length > 0) {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')
      }
      if (content.length > 0) {
        Text(content)
          .fontSize(14)
          .fontColor('#6b7280')
          .width('100%')
      }
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#ffffff')
    .borderRadius(18)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildCurrentPage() {
    if (this.currentPage === AppPage.Login) {
      this.buildLoginPage()
    } else if (this.currentPage === AppPage.Home) {
      this.buildHomePage()
    } else if (this.currentPage === AppPage.ServerForm) {
      this.buildServerFormPage()
    } else if (this.currentPage === AppPage.Terminal) {
      this.buildTerminalPage()
    } else if (this.currentPage === AppPage.Sftp) {
      this.buildSftpPage()
    } else {
      this.buildSettingsPage()
    }
  }

  @Builder
  buildLoginPage() {
    Column({ space: 16 }) {
      Blank().height(30)
      PageHeader({ title: 'HarmonySSH22', subtitle: 'Mock 登录页 · 先保证能演示、能跳转、能扩展' })
      Column({ space: 12 }) {
        Text('连接信息')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')

        FieldLabel({ text: '后端地址' })
        TextInput({ text: this.backendUrl, placeholder: '请输入后端地址' })
          .onChange((value: string) => this.backendUrl = value)
          .height(44)
          .width('100%')
          .backgroundColor('#f9fafb')
          .borderRadius(12)

        FieldLabel({ text: '用户名' })
        TextInput({ text: this.username, placeholder: '请输入用户名' })
          .onChange((value: string) => this.username = value)
          .height(44)
          .width('100%')
          .backgroundColor('#f9fafb')
          .borderRadius(12)

        FieldLabel({ text: '密码' })
        TextInput({ text: this.password, placeholder: '请输入密码' })
          .type(InputType.Password)
          .onChange((value: string) => this.password = value)
          .height(44)
          .width('100%')
          .backgroundColor('#f9fafb')
          .borderRadius(12)
      }
      .padding(16)
      .width('100%')
      .backgroundColor('#ffffff')
      .borderRadius(18)
      .alignItems(HorizontalAlign.Start)

      ActionButton({
        text: 'Mock 登录',
        onPress: () => {
          this.session = MockAuthService.login(this.backendUrl, this.username, this.password)
          this.refreshServers()
          this.currentPage = AppPage.Home
        }
      })
    }
    .width('100%')
  }

  @Builder
  buildHomePage() {
    Column({ space: 16 }) {
      PageHeader({ title: '服务器列表', subtitle: this.session.username + ' · ' + this.session.backendUrl })
      ActionButton({
        text: '新增服务器',
        onPress: () => {
          this.editingServer = MockServerService.createEmpty()
          this.currentPage = AppPage.ServerForm
        }
      })
      ForEach(this.servers, (item: ServerItem) => {
        ServerListCard({
          item: item,
          onEdit: (server: ServerItem) => {
            this.editingServer = cloneServerItem(server)
            this.currentPage = AppPage.ServerForm
          },
          onTerminal: (server: ServerItem) => {
            this.selectedServer = cloneServerItem(server)
            this.terminalLines = MockTerminalService.createWelcomeLines(server)
            this.currentPage = AppPage.Terminal
          },
          onSftp: (server: ServerItem) => {
            this.selectedServer = cloneServerItem(server)
            this.currentSftpPath = '/'
            this.sftpList = MockSftpService.list('/')
            this.currentPage = AppPage.Sftp
          }
        })
      }, (item: ServerItem) => item.id)
    }
    .width('100%')
  }

  @Builder
  buildServerFormPage() {
    Column({ space: 16 }) {
      PageHeader({ title: '服务器表单', subtitle: '新增 / 编辑服务器（Mock 持久化）' })
      Column({ space: 12 }) {
        Text('基础信息')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')

        FieldLabel({ text: '名称' })
        TextInput({ text: this.editingServer.name, placeholder: '如：生产机 A' })
          .onChange((value: string) => this.editingServer.name = value)
          .height(44)
          .backgroundColor('#f9fafb')
          .borderRadius(12)

        FieldLabel({ text: '主机地址' })
        TextInput({ text: this.editingServer.host, placeholder: '如：192.168.1.20' })
          .onChange((value: string) => this.editingServer.host = value)
          .height(44)
          .backgroundColor('#f9fafb')
          .borderRadius(12)

        FieldLabel({ text: '端口' })
        TextInput({ text: this.editingServer.port.toString(), placeholder: '22' })
          .type(InputType.Number)
          .onChange((value: string) => this.editingServer.port = Number(value) || 22)
          .height(44)
          .backgroundColor('#f9fafb')
          .borderRadius(12)

        FieldLabel({ text: '用户名' })
        TextInput({ text: this.editingServer.username, placeholder: '如：root' })
          .onChange((value: string) => this.editingServer.username = value)
          .height(44)
          .backgroundColor('#f9fafb')
          .borderRadius(12)

        FieldLabel({ text: '备注' })
        TextInput({ text: this.editingServer.remark, placeholder: '可选备注' })
          .onChange((value: string) => this.editingServer.remark = value)
          .height(44)
          .backgroundColor('#f9fafb')
          .borderRadius(12)
      }
      .padding(16)
      .width('100%')
      .backgroundColor('#ffffff')
      .borderRadius(18)
      .alignItems(HorizontalAlign.Start)

      ActionButton({
        text: '保存并返回首页',
        onPress: () => {
          if (this.editingServer.name.trim().length === 0) {
            this.editingServer.name = '未命名服务器'
          }
          if (this.editingServer.host.trim().length === 0) {
            this.editingServer.host = '127.0.0.1'
          }
          if (this.editingServer.username.trim().length === 0) {
            this.editingServer.username = 'root'
          }
          MockServerService.createOrUpdate(this.editingServer)
          this.refreshServers()
          this.currentPage = AppPage.Home
        }
      })
      ActionButton({ text: '取消', type: 'secondary', onPress: () => this.currentPage = AppPage.Home })
    }
    .width('100%')
  }

  @Builder
  buildTerminalPage() {
    Column({ space: 16 }) {
      PageHeader({
        title: '终端',
        subtitle: this.selectedServer ? this.selectedServer.username + '@' + this.selectedServer.host : '未选择服务器'
      })
      Column({ space: 10 }) {
        Text('输出')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')
        ForEach(this.terminalLines, (line: TerminalLine) => {
          Text(line.content)
            .width('100%')
            .fontSize(13)
            .fontColor(line.type === TerminalLineType.Command ? '#60a5fa' : line.type === TerminalLineType.Info ? '#10b981' : '#e5e7eb')
            .backgroundColor('#111827')
            .padding(10)
            .borderRadius(10)
        }, (line: TerminalLine) => line.id)
      }
      .padding(16)
      .width('100%')
      .backgroundColor('#ffffff')
      .borderRadius(18)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 12 }) {
        Text('输入命令')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')
        TextInput({ text: this.terminalInput, placeholder: '输入命令，例如 ls / pwd / whoami' })
          .onChange((value: string) => this.terminalInput = value)
          .height(44)
          .backgroundColor('#f9fafb')
          .borderRadius(12)
        ActionButton({
          text: '执行 Mock 命令',
          onPress: () => {
            const nextLines: TerminalLine[] = MockTerminalService.execute(this.terminalInput, this.session.username)
            const merged: TerminalLine[] = []
            let i: number = 0
            for (i = 0; i < this.terminalLines.length; i++) {
              merged.push(this.terminalLines[i])
            }
            for (i = 0; i < nextLines.length; i++) {
              merged.push(nextLines[i])
            }
            this.terminalLines = merged
          }
        })
      }
      .padding(16)
      .width('100%')
      .backgroundColor('#ffffff')
      .borderRadius(18)
      .alignItems(HorizontalAlign.Start)

      ActionButton({ text: '返回首页', type: 'secondary', onPress: () => this.currentPage = AppPage.Home })
    }
    .width('100%')
  }

  @Builder
  buildSftpPage() {
    Column({ space: 16 }) {
      PageHeader({ title: 'SFTP 文件管理', subtitle: '当前目录：' + this.currentSftpPath })
      Row({ space: 12 }) {
        Button('返回上级')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor('#374151')
          .onClick(() => {
            this.currentSftpPath = MockSftpService.goParent(this.currentSftpPath)
            this.sftpList = MockSftpService.list(this.currentSftpPath)
          })
        Button('回到根目录')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor('#2563eb')
          .onClick(() => {
            this.currentSftpPath = '/'
            this.sftpList = MockSftpService.list('/')
          })
      }
      ForEach(this.sftpList, (item: SftpNode) => {
        Row() {
          Column({ space: 4 }) {
            Text(item.isDirectory ? '📁 ' + item.name : '📄 ' + item.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Text(item.path + (item.size.length > 0 ? ' · ' + item.size : ''))
              .fontSize(12)
              .fontColor('#6b7280')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          if (item.isDirectory) {
            Button('进入')
              .type(ButtonType.Capsule)
              .backgroundColor('#059669')
              .onClick(() => {
                this.currentSftpPath = item.path
                this.sftpList = MockSftpService.list(item.path)
              })
          }
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#ffffff')
        .borderRadius(18)
      }, (item: SftpNode) => item.path)
      ActionButton({ text: '返回首页', type: 'secondary', onPress: () => this.currentPage = AppPage.Home })
    }
    .width('100%')
  }

  @Builder
  buildSettingsPage() {
    Column({ space: 16 }) {
      PageHeader({ title: '设置', subtitle: '本阶段全部为 Mock 交互' })

      Column({ space: 12 }) {
        Text('账号与数据')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')
        ActionButton({ text: '修改密码（Mock）', onPress: () => {} })
        ActionButton({ text: '备份配置（Mock）', type: 'secondary', onPress: () => {} })
        ActionButton({ text: '恢复配置（Mock）', type: 'secondary', onPress: () => {} })
      }
      .padding(16)
      .width('100%')
      .backgroundColor('#ffffff')
      .borderRadius(18)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 8 }) {
        Text('当前会话')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')
        Text('用户：' + this.session.username)
          .fontSize(14)
        Text('后端：' + this.session.backendUrl)
          .fontSize(14)
          .fontColor('#6b7280')
      }
      .padding(16)
      .width('100%')
      .backgroundColor('#ffffff')
      .borderRadius(18)
      .alignItems(HorizontalAlign.Start)

      ActionButton({
        text: '退出登录',
        type: 'danger',
        onPress: () => {
          MockAuthService.logout()
          this.session = MockAuthService.getSession()
          this.currentPage = AppPage.Login
        }
      })
    }
    .width('100%')
  }

  private refreshServers(): void {
    this.servers = MockServerService.list()
  }
}
