import { ServerItem, SftpNode, TerminalLine, UserSession } from '../models/AppModels';

export class MockAuthService {
  private static session: UserSession = {
    backendUrl: 'http://192.168.1.10:8080',
    username: 'admin',
    loggedIn: false
  }

  static getDefaultBackendUrl(): string {
    return this.session.backendUrl
  }

  static login(backendUrl: string, username: string, _password: string): UserSession {
    this.session = {
      backendUrl: backendUrl.trim().length > 0 ? backendUrl.trim() : this.session.backendUrl,
      username: username.trim().length > 0 ? username.trim() : 'admin',
      loggedIn: true
    }
    return this.session
  }

  static logout(): void {
    this.session.loggedIn = false
  }

  static getSession(): UserSession {
    return this.session
  }
}

export class MockServerService {
  private static servers: ServerItem[] = [
    {
      id: '1',
      name: '生产机 A',
      host: '192.168.1.20',
      port: 22,
      username: 'root',
      remark: '主业务节点'
    },
    {
      id: '2',
      name: '测试机 B',
      host: '192.168.1.30',
      port: 22,
      username: 'dev',
      remark: '功能验证环境'
    }
  ]

  static list(): ServerItem[] {
    return this.servers.map(item => ({ ...item }))
  }

  static getById(id: string): ServerItem | null {
    const found = this.servers.find(item => item.id === id)
    return found ? { ...found } : null
  }

  static createOrUpdate(server: ServerItem): void {
    const index = this.servers.findIndex(item => item.id === server.id)
    if (index >= 0) {
      this.servers[index] = { ...server }
      return
    }
    this.servers.unshift({ ...server })
  }

  static createEmpty(): ServerItem {
    return {
      id: `${Date.now()}`,
      name: '',
      host: '',
      port: 22,
      username: '',
      remark: ''
    }
  }
}

export class MockTerminalService {
  static createWelcomeLines(server: ServerItem | null): TerminalLine[] {
    const serverName = server ? server.name : '未选择服务器'
    return [
      { id: '1', type: 'info', content: `Connected to ${serverName} (Mock)` },
      { id: '2', type: 'output', content: 'Welcome to HarmonySSH22 mock terminal.' },
      { id: '3', type: 'output', content: 'Try: ls, pwd, whoami, cat /etc/hosts' }
    ]
  }

  static execute(command: string, sessionUser: string): TerminalLine[] {
    const trimmed = command.trim()
    if (trimmed.length === 0) {
      return [{ id: `${Date.now()}`, type: 'output', content: '' }]
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

    return [
      { id: `${Date.now()}-1`, type: 'command', content: `$ ${trimmed}` },
      { id: `${Date.now()}-2`, type: 'output', content: result }
    ]
  }
}

export class MockSftpService {
  private static tree: SftpNode = {
    name: '/',
    path: '/',
    isDirectory: true,
    children: [
      {
        name: 'home',
        path: '/home',
        isDirectory: true,
        children: [
          {
            name: 'admin',
            path: '/home/admin',
            isDirectory: true,
            children: [
              { name: 'readme.txt', path: '/home/admin/readme.txt', isDirectory: false, size: '2 KB' },
              { name: 'backup.zip', path: '/home/admin/backup.zip', isDirectory: false, size: '18 MB' }
            ]
          }
        ]
      },
      {
        name: 'var',
        path: '/var',
        isDirectory: true,
        children: [
          { name: 'log', path: '/var/log', isDirectory: true, children: [
            { name: 'app.log', path: '/var/log/app.log', isDirectory: false, size: '320 KB' },
            { name: 'error.log', path: '/var/log/error.log', isDirectory: false, size: '28 KB' }
          ] }
        ]
      },
      { name: 'etc', path: '/etc', isDirectory: true, children: [
        { name: 'hosts', path: '/etc/hosts', isDirectory: false, size: '1 KB' }
      ] }
    ]
  }

  static list(path: string): SftpNode[] {
    const node = this.findNode(path, this.tree)
    if (!node || !node.children) {
      return []
    }
    return node.children.map(item => ({ ...item, children: item.children ? [...item.children] : undefined }))
  }

  static goParent(path: string): string {
    if (path === '/' || path.length === 0) {
      return '/'
    }
    const parts = path.split('/').filter(item => item.length > 0)
    parts.pop()
    return parts.length === 0 ? '/' : '/' + parts.join('/')
  }

  private static findNode(path: string, current: SftpNode): SftpNode | null {
    if (current.path === path) {
      return current
    }
    if (!current.children) {
      return null
    }
    for (let i = 0; i < current.children.length; i++) {
      const result = this.findNode(path, current.children[i])
      if (result) {
        return result
      }
    }
    return null
  }
}
