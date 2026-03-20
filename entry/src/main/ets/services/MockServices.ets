import {
  ServerItem,
  SftpNode,
  TerminalLine,
  TerminalLineType,
  UserSession,
  cloneServerItem,
  cloneSftpNode,
  cloneUserSession
} from '../models/AppModels';

export class MockAuthService {
  private static session: UserSession = MockAuthService.createDefaultSession()

  private static createDefaultSession(): UserSession {
    const session: UserSession = new UserSession()
    session.backendUrl = 'http://192.168.1.10:8080'
    session.username = 'admin'
    session.loggedIn = false
    return session
  }

  static getDefaultBackendUrl(): string {
    return MockAuthService.session.backendUrl
  }

  static login(backendUrl: string, username: string, _password: string): UserSession {
    const nextSession: UserSession = new UserSession()
    nextSession.backendUrl = backendUrl.trim().length > 0 ? backendUrl.trim() : MockAuthService.session.backendUrl
    nextSession.username = username.trim().length > 0 ? username.trim() : 'admin'
    nextSession.loggedIn = true
    MockAuthService.session = nextSession
    return cloneUserSession(MockAuthService.session)
  }

  static logout(): void {
    MockAuthService.session.loggedIn = false
  }

  static getSession(): UserSession {
    return cloneUserSession(MockAuthService.session)
  }
}

export class MockServerService {
  private static servers: ServerItem[] = MockServerService.createInitialServers()

  private static createInitialServers(): ServerItem[] {
    const items: ServerItem[] = []

    const first: ServerItem = new ServerItem()
    first.id = '1'
    first.name = '生产机 A'
    first.host = '192.168.1.20'
    first.port = 22
    first.username = 'root'
    first.remark = '主业务节点'
    items.push(first)

    const second: ServerItem = new ServerItem()
    second.id = '2'
    second.name = '测试机 B'
    second.host = '192.168.1.30'
    second.port = 22
    second.username = 'dev'
    second.remark = '功能验证环境'
    items.push(second)

    return items
  }

  static list(): ServerItem[] {
    const result: ServerItem[] = []
    for (let i = 0; i < MockServerService.servers.length; i++) {
      result.push(cloneServerItem(MockServerService.servers[i]))
    }
    return result
  }

  static getById(id: string): ServerItem | null {
    for (let i = 0; i < MockServerService.servers.length; i++) {
      const item = MockServerService.servers[i]
      if (item.id === id) {
        return cloneServerItem(item)
      }
    }
    return null
  }

  static createOrUpdate(server: ServerItem): void {
    for (let i = 0; i < MockServerService.servers.length; i++) {
      if (MockServerService.servers[i].id === server.id) {
        MockServerService.servers[i] = cloneServerItem(server)
        return
      }
    }
    MockServerService.servers.unshift(cloneServerItem(server))
  }

  static createEmpty(): ServerItem {
    const item: ServerItem = new ServerItem()
    item.id = Date.now().toString()
    return item
  }
}

export class MockTerminalService {
  static createWelcomeLines(server: ServerItem | null): TerminalLine[] {
    const serverName = server ? server.name : '未选择服务器'
    const lines: TerminalLine[] = []

    const line1: TerminalLine = new TerminalLine()
    line1.id = '1'
    line1.type = TerminalLineType.Info
    line1.content = 'Connected to ' + serverName + ' (Mock)'
    lines.push(line1)

    const line2: TerminalLine = new TerminalLine()
    line2.id = '2'
    line2.type = TerminalLineType.Output
    line2.content = 'Welcome to HarmonySSH22 mock terminal.'
    lines.push(line2)

    const line3: TerminalLine = new TerminalLine()
    line3.id = '3'
    line3.type = TerminalLineType.Output
    line3.content = 'Try: ls, pwd, whoami, cat /etc/hosts'
    lines.push(line3)

    return lines
  }

  static execute(command: string, sessionUser: string): TerminalLine[] {
    const trimmed = command.trim()
    const lines: TerminalLine[] = []

    if (trimmed.length === 0) {
      const emptyLine: TerminalLine = new TerminalLine()
      emptyLine.id = Date.now().toString()
      emptyLine.type = TerminalLineType.Output
      emptyLine.content = ''
      lines.push(emptyLine)
      return lines
    }

    let result = 'command not found (mock): ' + trimmed
    if (trimmed === 'pwd') {
      result = '/home/' + sessionUser
    } else if (trimmed === 'ls') {
      result = 'logs  uploads  backup  readme.txt'
    } else if (trimmed === 'whoami') {
      result = sessionUser
    } else if (trimmed === 'cat /etc/hosts') {
      result = '127.0.0.1 localhost\n192.168.1.20 prod-a\n192.168.1.30 test-b'
    }

    const commandLine: TerminalLine = new TerminalLine()
    commandLine.id = Date.now().toString() + '-1'
    commandLine.type = TerminalLineType.Command
    commandLine.content = '$ ' + trimmed
    lines.push(commandLine)

    const resultLine: TerminalLine = new TerminalLine()
    resultLine.id = Date.now().toString() + '-2'
    resultLine.type = TerminalLineType.Output
    resultLine.content = result
    lines.push(resultLine)

    return lines
  }
}

export class MockSftpService {
  private static tree: SftpNode = MockSftpService.createTree()

  private static createTree(): SftpNode {
    const root: SftpNode = new SftpNode()
    root.name = '/'
    root.path = '/'
    root.isDirectory = true

    const home: SftpNode = new SftpNode()
    home.name = 'home'
    home.path = '/home'
    home.isDirectory = true

    const admin: SftpNode = new SftpNode()
    admin.name = 'admin'
    admin.path = '/home/admin'
    admin.isDirectory = true

    const readme: SftpNode = new SftpNode()
    readme.name = 'readme.txt'
    readme.path = '/home/admin/readme.txt'
    readme.isDirectory = false
    readme.size = '2 KB'

    const backup: SftpNode = new SftpNode()
    backup.name = 'backup.zip'
    backup.path = '/home/admin/backup.zip'
    backup.isDirectory = false
    backup.size = '18 MB'

    admin.children = [readme, backup]
    home.children = [admin]

    const varDir: SftpNode = new SftpNode()
    varDir.name = 'var'
    varDir.path = '/var'
    varDir.isDirectory = true

    const logDir: SftpNode = new SftpNode()
    logDir.name = 'log'
    logDir.path = '/var/log'
    logDir.isDirectory = true

    const appLog: SftpNode = new SftpNode()
    appLog.name = 'app.log'
    appLog.path = '/var/log/app.log'
    appLog.isDirectory = false
    appLog.size = '320 KB'

    const errorLog: SftpNode = new SftpNode()
    errorLog.name = 'error.log'
    errorLog.path = '/var/log/error.log'
    errorLog.isDirectory = false
    errorLog.size = '28 KB'

    logDir.children = [appLog, errorLog]
    varDir.children = [logDir]

    const etcDir: SftpNode = new SftpNode()
    etcDir.name = 'etc'
    etcDir.path = '/etc'
    etcDir.isDirectory = true

    const hosts: SftpNode = new SftpNode()
    hosts.name = 'hosts'
    hosts.path = '/etc/hosts'
    hosts.isDirectory = false
    hosts.size = '1 KB'

    const nginx: SftpNode = new SftpNode()
    nginx.name = 'nginx.conf'
    nginx.path = '/etc/nginx.conf'
    nginx.isDirectory = false
    nginx.size = '4 KB'

    etcDir.children = [hosts, nginx]
    root.children = [home, varDir, etcDir]
    return root
  }

  static list(path: string): SftpNode[] {
    const node = MockSftpService.findNode(path, MockSftpService.tree)
    if (node === null) {
      return []
    }
    const result: SftpNode[] = []
    for (let i = 0; i < node.children.length; i++) {
      result.push(cloneSftpNode(node.children[i]))
    }
    return result
  }

  static goParent(path: string): string {
    if (path === '/' || path.length === 0) {
      return '/'
    }
    const parts = path.split('/').filter((item: string) => item.length > 0)
    parts.pop()
    if (parts.length === 0) {
      return '/'
    }
    return '/' + parts.join('/')
  }

  static previewFile(path: string): string {
    const node = MockSftpService.findNode(path, MockSftpService.tree)
    if (node === null) {
      return '文件不存在（Mock）'
    }
    if (node.isDirectory) {
      return '这是目录，不能直接预览。'
    }
    if (path === '/etc/hosts') {
      return '127.0.0.1 localhost\n192.168.1.20 prod-a\n192.168.1.30 test-b'
    }
    if (path === '/etc/nginx.conf') {
      return 'server {\n  listen 80;\n  server_name mock.local;\n  location / {\n    proxy_pass http://127.0.0.1:8080;\n  }\n}'
    }
    if (path === '/var/log/app.log') {
      return '[INFO] HarmonySSH22 mock started\n[INFO] polling completed\n[WARN] this is only a preview mock'
    }
    if (path === '/var/log/error.log') {
      return '[ERROR] no real backend connected\n[INFO] mock mode keeps running'
    }
    return '预览内容（Mock）\n文件：' + node.name + '\n大小：' + node.size
  }

  static deleteNode(path: string): boolean {
    if (path === '/') {
      return false
    }
    const parent = MockSftpService.findParent(path, MockSftpService.tree)
    if (parent === null) {
      return false
    }
    const nextChildren: SftpNode[] = []
    let removed = false
    for (let i = 0; i < parent.children.length; i++) {
      if (parent.children[i].path === path) {
        removed = true
      } else {
        nextChildren.push(parent.children[i])
      }
    }
    if (!removed) {
      return false
    }
    parent.children = nextChildren
    return true
  }

  static renameNode(path: string, nextName: string): string {
    const node = MockSftpService.findNode(path, MockSftpService.tree)
    if (node === null) {
      return path
    }
    const trimmed = nextName.trim()
    if (trimmed.length === 0) {
      return node.path
    }
    const parentPath = MockSftpService.goParent(node.path)
    node.name = trimmed
    if (parentPath === '/') {
      node.path = '/' + trimmed
    } else {
      node.path = parentPath + '/' + trimmed
    }
    MockSftpService.refreshChildrenPath(node)
    return node.path
  }

  static downloadNode(path: string): string {
    const node = MockSftpService.findNode(path, MockSftpService.tree)
    if (node === null) {
      return '下载失败：目标不存在（Mock）'
    }
    if (node.isDirectory) {
      return '已打包下载目录：' + node.path + '（Mock ZIP）'
    }
    return '开始下载文件：' + node.path + '（Mock）'
  }

  static downloadBatch(paths: string[]): string {
    if (paths.length === 0) {
      return '请先选择文件或文件夹'
    }
    return '已打包下载 ' + paths.length.toString() + ' 个项目（Mock ZIP）'
  }

  private static refreshChildrenPath(node: SftpNode): void {
    if (!node.isDirectory) {
      return
    }
    for (let i = 0; i < node.children.length; i++) {
      const child = node.children[i]
      child.path = node.path === '/' ? '/' + child.name : node.path + '/' + child.name
      MockSftpService.refreshChildrenPath(child)
    }
  }

  private static findParent(path: string, current: SftpNode): SftpNode | null {
    for (let i = 0; i < current.children.length; i++) {
      if (current.children[i].path === path) {
        return current
      }
      const nested = MockSftpService.findParent(path, current.children[i])
      if (nested !== null) {
        return nested
      }
    }
    return null
  }

  private static findNode(path: string, current: SftpNode): SftpNode | null {
    if (current.path === path) {
      return current
    }
    for (let i = 0; i < current.children.length; i++) {
      const result = MockSftpService.findNode(path, current.children[i])
      if (result !== null) {
        return result
      }
    }
    return null
  }
}
