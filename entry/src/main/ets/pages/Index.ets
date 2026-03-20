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
  @State confirmPassword: string = '123456'
  @State enableOtp: boolean = false
  @State otpCode: string = ''
  @State showConfirmPassword: boolean = false
  @State loginMessage: string = ''

  @State servers: ServerItem[] = MockServerService.list()
  @State editingServer: ServerItem = MockServerService.createEmpty()
  @State selectedServer: ServerItem | null = null

  @State terminalInput: string = 'ls'
  @State terminalLines: TerminalLine[] = []
  @State terminalStatusMessage: string = '在线测试'

  @State currentSftpPath: string = '/'
  @State sftpList: SftpNode[] = MockSftpService.list('/')
  @State sftpNotice: string = '点击文件夹直接进入，点击文件预览（Mock）'
  @State sftpPreviewTitle: string = '未选择文件'
  @State sftpPreviewContent: string = '点击文件后，这里会显示预览内容。'
  @State sftpSelectedPaths: string[] = []
  @State sftpRenameInput: string = ''

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
      if (this.currentPage === AppPage.Home) {
        this.buildHomeLayout()
      } else if (this.currentPage === AppPage.Sftp) {
        this.buildSftpLayout()
      } else if (this.currentPage === AppPage.Terminal) {
        this.buildTerminalPage()
      } else {
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentPage === AppPage.Terminal ? '#050a10' : '#f3f4f6')
  }

  @Builder
  buildHomeLayout() {
    Column({ space: 0 }) {
      Scroll() {
        Column({ space: 16 }) {
          this.buildHomePage()
        }
        .padding({ left: 16, right: 16, top: 20, bottom: 20 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)

      Column({ space: 12 }) {
        ActionButton({
          text: '新增服务器',
          onPress: () => {
            this.editingServer = MockServerService.createEmpty()
            this.currentPage = AppPage.ServerForm
          }
        })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .width('100%')
      .backgroundColor('#f3f4f6')

      BottomTabs({
        currentPage: AppPage.Home,
        tabs: this.bottomTabs,
        onChange: (page: AppPage) => {
          this.currentPage = page
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildSftpLayout() {
    Column({ space: 0 }) {
      Column({ space: 12 }) {
        PageHeader({ title: 'SFTP 文件管理', subtitle: '当前目录：' + this.currentSftpPath })
        Text(this.sftpNotice)
          .fontSize(13)
          .fontColor('#6b7280')
          .width('100%')
        Row({ space: 12 }) {
          Button('回到首页')
            .type(ButtonType.Capsule)
            .layoutWeight(1)
            .backgroundColor('#111827')
            .onClick(() => this.currentPage = AppPage.Home)
          Button('回到根目录')
            .type(ButtonType.Capsule)
            .layoutWeight(1)
            .backgroundColor('#2563eb')
            .onClick(() => {
              this.currentSftpPath = '/'
              this.sftpList = MockSftpService.list('/')
              this.sftpSelectedPaths = []
              this.sftpNotice = '已回到根目录（Mock）'
            })
        }
      }
      .padding({ left: 16, right: 16, top: 20, bottom: 12 })
      .width('100%')
      .backgroundColor('#f3f4f6')

      Scroll() {
        Column({ space: 12 }) {
          this.buildSftpPage()
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 20 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)

      Column({ space: 12 }) {
        Button(this.sftpSelectedPaths.length > 0 ? '批量打包下载（' + this.sftpSelectedPaths.length.toString() + '）' : '批量打包下载')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(44)
          .fontColor('#ffffff')
          .backgroundColor(this.sftpSelectedPaths.length > 0 ? '#059669' : '#9ca3af')
          .enabled(this.sftpSelectedPaths.length > 0)
          .onClick(() => {
            this.sftpNotice = MockSftpService.downloadBatch(this.sftpSelectedPaths)
          })
        ActionButton({
          text: '返回上级',
          type: 'secondary',
          onPress: () => {
            this.currentSftpPath = MockSftpService.goParent(this.currentSftpPath)
            this.sftpList = MockSftpService.list(this.currentSftpPath)
            this.sftpSelectedPaths = []
            this.sftpNotice = '已返回上级目录：' + this.currentSftpPath
          }
        })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .width('100%')
      .backgroundColor('#f3f4f6')

      BottomTabs({
        currentPage: AppPage.Home,
        tabs: this.bottomTabs,
        onChange: (page: AppPage) => {
          this.currentPage = page
        }
      })
    }
    .width('100%')
    .height('100%')
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
    Column({ space: 0 }) {
      Row() {
        Blank()
          .width(24)
        Text('登录')
          .layoutWeight(1)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ffffff')
          .textAlign(TextAlign.Center)
        Blank()
          .width(24)
      }
      .height(60)
      .width('100%')
      .padding({ left: 16, right: 16 })
      .backgroundColor('#2F7FD8')

      Scroll() {
        Column({ space: 12 }) {
          Column({ space: 12 }) {
            Text('后端地址')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Row({ space: 8 }) {
              TextInput({ text: this.backendUrl, placeholder: 'http://api.server.com' })
                .layoutWeight(1)
                .height(48)
                .fontSize(15)
                .backgroundColor('#ffffff')
                .borderRadius(10)
                .border({ width: 1, color: '#dddddd' })
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => {
                  this.backendUrl = value
                  if (this.loginMessage.length > 0) {
                    this.loginMessage = ''
                  }
                })
              Button('◐')
                .type(ButtonType.Capsule)
                .width(42)
                .height(42)
                .backgroundColor('#ffffff')
                .border({ width: 1, color: '#dddddd' })
                .fontColor('#7b8794')
                .fontSize(16)
                .onClick(() => {
                  this.loginMessage = this.isValidBackendUrl(this.backendUrl) ? '后端地址格式正确（Mock）' : '后端地址格式不正确'
                })
            }
            .width('100%')

            Row({ space: 10 }) {
              Text('◉')
                .width(18)
                .textAlign(TextAlign.Center)
                .fontSize(14)
                .fontColor('#9aa0a6')
              TextInput({ text: this.username, placeholder: '用户名' })
                .layoutWeight(1)
                .height(48)
                .fontSize(15)
                .backgroundColor('#ffffff')
                .onChange((value: string) => {
                  this.username = value
                  if (this.loginMessage.length > 0) {
                    this.loginMessage = ''
                  }
                })
            }
            .padding({ left: 12, right: 12 })
            .width('100%')
            .height(48)
            .backgroundColor('#ffffff')
            .borderRadius(10)
            .border({ width: 1, color: '#dddddd' })

            Row({ space: 10 }) {
              Text('■')
                .width(18)
                .textAlign(TextAlign.Center)
                .fontSize(13)
                .fontColor('#9aa0a6')
              TextInput({ text: this.password, placeholder: '密码' })
                .layoutWeight(1)
                .height(48)
                .fontSize(15)
                .type(InputType.Password)
                .backgroundColor('#ffffff')
                .onChange((value: string) => {
                  this.password = value
                  if (this.loginMessage.length > 0) {
                    this.loginMessage = ''
                  }
                })
            }
            .padding({ left: 12, right: 12 })
            .width('100%')
            .height(48)
            .backgroundColor('#ffffff')
            .borderRadius(10)
            .border({ width: 1, color: '#dddddd' })

            Row({ space: 10 }) {
              Text('■')
                .width(18)
                .textAlign(TextAlign.Center)
                .fontSize(13)
                .fontColor('#9aa0a6')
              TextInput({ text: this.confirmPassword, placeholder: '密码' })
                .layoutWeight(1)
                .height(48)
                .fontSize(15)
                .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
                .backgroundColor('#ffffff')
                .onChange((value: string) => {
                  this.confirmPassword = value
                  if (this.loginMessage.length > 0) {
                    this.loginMessage = ''
                  }
                })
              Button(this.showConfirmPassword ? '◉' : '◎')
                .type(ButtonType.Capsule)
                .width(34)
                .height(34)
                .backgroundColor('#ffffff')
                .fontColor('#9aa0a6')
                .fontSize(14)
                .onClick(() => this.showConfirmPassword = !this.showConfirmPassword)
            }
            .padding({ left: 12, right: 12 })
            .width('100%')
            .height(48)
            .backgroundColor('#ffffff')
            .borderRadius(10)
            .border({ width: 1, color: '#dddddd' })

            Row({ space: 10 }) {
              Checkbox()
                .select(this.enableOtp)
                .onChange((checked: boolean) => {
                  this.enableOtp = checked
                  if (!checked) {
                    this.otpCode = ''
                  }
                  if (this.loginMessage.length > 0) {
                    this.loginMessage = ''
                  }
                })
              Text('二次验证码')
                .fontSize(14)
                .fontColor('#333333')
            }
            .width('100%')

            Row({ space: 10 }) {
              Text('⊘')
                .width(18)
                .textAlign(TextAlign.Center)
                .fontSize(14)
                .fontColor(this.enableOtp ? '#9aa0a6' : '#cfd4da')
              TextInput({ text: this.otpCode, placeholder: '请输入6位验证码' })
                .layoutWeight(1)
                .height(48)
                .fontSize(15)
                .enabled(this.enableOtp)
                .type(InputType.Number)
                .backgroundColor('#ffffff')
                .opacity(this.enableOtp ? 1 : 0.55)
                .onChange((value: string) => {
                  this.otpCode = value.replace(/[^0-9]/g, '').slice(0, 6)
                  if (this.loginMessage.length > 0) {
                    this.loginMessage = ''
                  }
                })
            }
            .padding({ left: 12, right: 12 })
            .width('100%')
            .height(48)
            .backgroundColor('#ffffff')
            .borderRadius(10)
            .border({ width: 1, color: this.enableOtp ? '#dddddd' : '#e5e7eb' })
            .opacity(this.enableOtp ? 1 : 0.75)

            if (this.loginMessage.length > 0) {
              Text(this.loginMessage)
                .fontSize(12)
                .fontColor(this.loginMessage.indexOf('正确') >= 0 || this.loginMessage.indexOf('通过') >= 0 ? '#2F7FD8' : '#E53935')
                .width('100%')
            }

            Button('登录')
              .type(ButtonType.Capsule)
              .width('100%')
              .height(48)
              .backgroundColor('#4d9be6')
              .fontColor('#ffffff')
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 16 })
              .shadow({ radius: 12, color: '#334d9be6', offsetX: 0, offsetY: 4 })
              .onClick(() => this.submitLogin())
          }
          .padding({ left: 16, right: 16, top: 18, bottom: 22 })
          .width('100%')
          .backgroundColor('#ffffff')
          .borderRadius(18)
          .alignItems(HorizontalAlign.Start)
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#eef1f5')
  }

  @Builder
  buildHomePage() {
    Column({ space: 16 }) {
      PageHeader({ title: '服务器列表', subtitle: this.session.username + ' · ' + this.session.backendUrl })

      if (this.servers.length === 0) {
        Column({ space: 8 }) {
          Text('还没有服务器')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
          Text('点击底部固定按钮新增第一台服务器')
            .fontSize(14)
            .fontColor('#6b7280')
        }
        .padding(20)
        .width('100%')
        .backgroundColor('#ffffff')
        .borderRadius(18)
        .alignItems(HorizontalAlign.Start)
      } else {
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
              this.terminalStatusMessage = '在线测试'
              this.currentPage = AppPage.Terminal
            },
            onSftp: (server: ServerItem) => {
              this.selectedServer = cloneServerItem(server)
              this.currentSftpPath = '/'
              this.sftpList = MockSftpService.list('/')
              this.sftpSelectedPaths = []
              this.sftpPreviewTitle = '未选择文件'
              this.sftpPreviewContent = '点击文件后，这里会显示预览内容。'
              this.sftpNotice = '点击文件夹直接进入，点击文件预览（Mock）'
              this.currentPage = AppPage.Sftp
            }
          })
        }, (item: ServerItem) => item.id)
      }
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
    Column({ space: 0 }) {
      Row({ space: 8 }) {
        Row({ space: 6 }) {
          Text('🖥')
            .fontSize(14)
          Text(this.getTerminalTitle())
            .layoutWeight(1)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#ffffff')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)

        Button('重连')
          .type(ButtonType.Capsule)
          .height(28)
          .fontSize(12)
          .padding({ left: 10, right: 10 })
          .backgroundColor('#1e90ff')
          .fontColor('#ffffff')
          .onClick(() => {
            this.terminalLines = MockTerminalService.createWelcomeLines(this.selectedServer)
            this.terminalStatusMessage = '在线测试'
          })

        Button('关闭')
          .type(ButtonType.Capsule)
          .height(28)
          .fontSize(12)
          .padding({ left: 10, right: 10 })
          .backgroundColor('#111827')
          .border({ width: 1, color: '#4b5563' })
          .fontColor('#ffffff')
          .onClick(() => this.currentPage = AppPage.Home)
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .width('100%')
      .backgroundColor('#111827')

      Row({ space: 8 }) {
        Text(this.terminalStatusMessage)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#d1d5db')
          .layoutWeight(1)
        Circle()
          .width(10)
          .height(10)
          .fill('#22c55e')
      }
      .padding({ left: 12, right: 12, top: 4, bottom: 6 })
      .width('100%')
      .backgroundColor('#111827')

      Stack({ alignContent: Alignment.TopStart }) {
        Scroll() {
          Column({ space: 4 }) {
            ForEach(this.terminalLines, (line: TerminalLine) => {
              Text(line.content)
                .width('100%')
                .fontSize(15)
                .fontColor(line.type === TerminalLineType.Info ? '#cbd5e1' : line.type === TerminalLineType.Command ? '#f8fafc' : '#d1d5db')
                .fontFamily('monospace')
                .lineHeight(22)
            }, (line: TerminalLine) => line.id)
            Text(this.buildTerminalPrompt() + this.terminalInput)
              .width('100%')
              .fontSize(15)
              .fontColor('#34d399')
              .fontFamily('monospace')
              .lineHeight(22)
          }
          .padding({ left: 10, right: 10, top: 0, bottom: 10 })
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Auto)

        TextInput({ text: this.terminalInput, placeholder: '' })
          .width('100%')
          .height('100%')
          .opacity(0.01)
          .backgroundColor(Color.Transparent)
          .caretColor('#ffffff')
          .onChange((value: string) => this.terminalInput = value)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#050a10')

      Scroll() {
        Row({ space: 6 }) {
          this.buildTerminalShortcut('ESC', 'ESC')
          this.buildTerminalShortcut('TAB', 'TAB')
          this.buildTerminalShortcut('Ctrl', 'Ctrl')
          this.buildTerminalShortcut('←', '←')
          this.buildTerminalShortcut('↑', '↑')
          this.buildTerminalShortcut('↓', '↓')
          this.buildTerminalShortcut('→', '→')
          this.buildTerminalShortcut('PgUp', 'PgUp')
          this.buildTerminalShortcut('PgDn', 'PgDn')
          this.buildTerminalShortcut('Ctrl+C', 'Ctrl+C', true)
          this.buildTerminalShortcut('Ctrl+V', 'Ctrl+V')
          this.buildTerminalShortcut('Ctrl+L', 'Ctrl+L')
          this.buildTerminalShortcut('回车', 'Enter', false, true)
        }
        .padding({ left: 10, right: 10, top: 8, bottom: 10 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .backgroundColor('#0f1720')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildSftpPage() {
    Column({ space: 12 }) {
      if (this.sftpList.length === 0) {
        Column({ space: 8 }) {
          Text('当前目录为空')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
          Text('可以返回上级，或回到根目录继续浏览。')
            .fontSize(14)
            .fontColor('#6b7280')
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#ffffff')
        .borderRadius(18)
        .alignItems(HorizontalAlign.Start)
      } else {
        ForEach(this.sftpList, (item: SftpNode) => {
          Column({ space: 12 }) {
            Row({ space: 10 }) {
              Checkbox({ name: item.path, group: 'sftp-select' })
                .select(this.isSftpSelected(item.path))
                .onChange((checked: boolean) => {
                  this.toggleSftpSelection(item.path, checked)
                })

              Column({ space: 4 }) {
                Text((item.isDirectory ? '📁 ' : '📄 ') + item.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#111827')
                Text(item.path + (item.size.length > 0 ? ' · ' + item.size : ''))
                  .fontSize(12)
                  .fontColor('#6b7280')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .onClick(() => {
                if (item.isDirectory) {
                  this.currentSftpPath = item.path
                  this.sftpList = MockSftpService.list(item.path)
                  this.sftpSelectedPaths = []
                  this.sftpNotice = '已进入目录：' + item.path
                } else {
                  this.sftpPreviewTitle = item.name
                  this.sftpPreviewContent = MockSftpService.previewFile(item.path)
                  this.sftpNotice = '正在预览文件：' + item.path
                }
              })
            }

            Row({ space: 8 }) {
              Button(item.isDirectory ? '打开' : '预览')
                .type(ButtonType.Capsule)
                .fontSize(12)
                .backgroundColor(item.isDirectory ? '#059669' : '#2563eb')
                .onClick(() => {
                  if (item.isDirectory) {
                    this.currentSftpPath = item.path
                    this.sftpList = MockSftpService.list(item.path)
                    this.sftpSelectedPaths = []
                    this.sftpNotice = '已进入目录：' + item.path
                  } else {
                    this.sftpPreviewTitle = item.name
                    this.sftpPreviewContent = MockSftpService.previewFile(item.path)
                    this.sftpNotice = '正在预览文件：' + item.path
                  }
                })
              Button('重命名')
                .type(ButtonType.Capsule)
                .fontSize(12)
                .backgroundColor('#7c3aed')
                .onClick(() => {
                  const nextName = item.isDirectory ? item.name + '_copy' : 'renamed_' + item.name
                  const nextPath = MockSftpService.renameNode(item.path, nextName)
                  this.currentSftpPath = MockSftpService.goParent(nextPath) === this.currentSftpPath ? this.currentSftpPath : this.currentSftpPath
                  this.sftpList = MockSftpService.list(this.currentSftpPath)
                  this.sftpNotice = '已重命名为：' + nextName + '（Mock）'
                  this.sftpRenameInput = nextName
                })
              Button(item.isDirectory ? '打包下载' : '下载')
                .type(ButtonType.Capsule)
                .fontSize(12)
                .backgroundColor('#0f766e')
                .onClick(() => {
                  this.sftpNotice = MockSftpService.downloadNode(item.path)
                })
              Button('删除')
                .type(ButtonType.Capsule)
                .fontSize(12)
                .backgroundColor('#dc2626')
                .onClick(() => {
                  const deleted = MockSftpService.deleteNode(item.path)
                  this.sftpList = MockSftpService.list(this.currentSftpPath)
                  this.removeSftpSelection(item.path)
                  this.sftpNotice = deleted ? '已删除：' + item.name + '（Mock）' : '删除失败：' + item.name
                })
            }
          }
          .padding(16)
          .width('100%')
          .backgroundColor('#ffffff')
          .borderRadius(18)
        }, (item: SftpNode) => item.path)
      }

      Column({ space: 8 }) {
        Text('文件预览')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')
        Text(this.sftpPreviewTitle)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2563eb')
          .width('100%')
        Text(this.sftpPreviewContent)
          .fontSize(13)
          .fontColor('#374151')
          .width('100%')
      }
      .padding(16)
      .width('100%')
      .backgroundColor('#ffffff')
      .borderRadius(18)
      .alignItems(HorizontalAlign.Start)
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

  private toggleSftpSelection(path: string, checked: boolean): void {
    const next: string[] = []
    let exists = false
    for (let i = 0; i < this.sftpSelectedPaths.length; i++) {
      if (this.sftpSelectedPaths[i] === path) {
        exists = true
        if (!checked) {
          continue
        }
      }
      next.push(this.sftpSelectedPaths[i])
    }
    if (checked && !exists) {
      next.push(path)
    }
    this.sftpSelectedPaths = next
  }

  private removeSftpSelection(path: string): void {
    const next: string[] = []
    for (let i = 0; i < this.sftpSelectedPaths.length; i++) {
      if (this.sftpSelectedPaths[i] !== path) {
        next.push(this.sftpSelectedPaths[i])
      }
    }
    this.sftpSelectedPaths = next
  }

  private isSftpSelected(path: string): boolean {
    for (let i = 0; i < this.sftpSelectedPaths.length; i++) {
      if (this.sftpSelectedPaths[i] === path) {
        return true
      }
    }
    return false
  }

  @Builder
  private buildTerminalShortcut(label: string, command: string, danger: boolean = false, accent: boolean = false) {
    Button(label)
      .type(ButtonType.Capsule)
      .height(34)
      .fontSize(12)
      .fontColor(danger ? '#fecaca' : '#e6edf7')
      .backgroundColor(danger ? '#3b1618' : accent ? '#123b33' : '#1f2933')
      .padding({ left: 10, right: 10 })
      .onClick(() => this.handleTerminalShortcut(command))
  }

  private buildTerminalPrompt(): string {
    if (this.selectedServer === null) {
      return 'root@mock:~# '
    }
    return this.selectedServer.username + '@' + this.selectedServer.name.toLowerCase() + ':~# '
  }

  private getTerminalTitle(): string {
    if (this.selectedServer === null) {
      return '未选择服务器'
    }
    if (this.selectedServer.name.trim().length > 0) {
      return this.selectedServer.name.trim()
    }
    return this.selectedServer.username + '@' + this.selectedServer.host
  }

  private handleTerminalShortcut(command: string): void {
    if (command === 'Enter') {
      this.runTerminalCommand()
      return
    }
    if (command === 'Ctrl+C') {
      this.terminalStatusMessage = '已发送中断信号（Mock）'
      return
    }
    if (command === 'Ctrl+L') {
      this.terminalLines = MockTerminalService.createWelcomeLines(this.selectedServer)
      this.terminalStatusMessage = '已清屏（Mock）'
      return
    }
    this.terminalStatusMessage = '快捷键：' + command + '（Mock）'
  }

  private runTerminalCommand(): void {
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
    this.terminalStatusMessage = '命令已执行（Mock）'
    this.terminalInput = ''
  }

  private isValidBackendUrl(url: string): boolean {
    const trimmed = url.trim()
    return trimmed.startsWith('http://') || trimmed.startsWith('https://')
  }

  private submitLogin(): void {
    if (!this.isValidBackendUrl(this.backendUrl)) {
      this.loginMessage = '请输入正确的后端地址'
      return
    }
    if (this.username.trim().length === 0) {
      this.loginMessage = '用户名不能为空'
      return
    }
    if (this.password.length < 6) {
      this.loginMessage = '密码至少 6 位'
      return
    }
    if (this.confirmPassword !== this.password) {
      this.loginMessage = '两次输入的密码不一致'
      return
    }
    if (this.enableOtp && this.otpCode.length !== 6) {
      this.loginMessage = '请输入 6 位验证码'
      return
    }
    this.loginMessage = '登录校验通过（Mock）'
    this.session = MockAuthService.login(this.backendUrl, this.username, this.password)
    this.refreshServers()
    this.currentPage = AppPage.Home
  }

  private refreshServers(): void {
    this.servers = MockServerService.list()
  }
}
