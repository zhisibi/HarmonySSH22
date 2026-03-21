export enum AppPage {
  Login = 'Login',
  Home = 'Home',
  ServerForm = 'ServerForm',
  Terminal = 'Terminal',
  Sftp = 'Sftp',
  TransferQueue = 'TransferQueue',
  Settings = 'Settings'
}

export enum TerminalLineType {
  Command = 'command',
  Output = 'output',
  Info = 'info'
}

export class UserSession {
  backendUrl: string = ''
  username: string = ''
  loggedIn: boolean = false
}

export class ServerItem {
  id: string = ''
  name: string = ''
  host: string = ''
  port: number = 22
  username: string = ''
  remark: string = ''
}

export class TerminalLine {
  id: string = ''
  type: TerminalLineType = TerminalLineType.Output
  content: string = ''
}

export class SftpNode {
  name: string = ''
  path: string = ''
  isDirectory: boolean = false
  size: string = ''
  children: SftpNode[] = []
}

export function cloneUserSession(source: UserSession): UserSession {
  const target: UserSession = new UserSession()
  target.backendUrl = source.backendUrl
  target.username = source.username
  target.loggedIn = source.loggedIn
  return target
}

export function cloneServerItem(source: ServerItem): ServerItem {
  const target: ServerItem = new ServerItem()
  target.id = source.id
  target.name = source.name
  target.host = source.host
  target.port = source.port
  target.username = source.username
  target.remark = source.remark
  return target
}

export function cloneTerminalLine(source: TerminalLine): TerminalLine {
  const target: TerminalLine = new TerminalLine()
  target.id = source.id
  target.type = source.type
  target.content = source.content
  return target
}

export function cloneSftpNode(source: SftpNode): SftpNode {
  const target: SftpNode = new SftpNode()
  target.name = source.name
  target.path = source.path
  target.isDirectory = source.isDirectory
  target.size = source.size
  const nextChildren: SftpNode[] = []
  for (let i = 0; i < source.children.length; i++) {
    nextChildren.push(cloneSftpNode(source.children[i]))
  }
  target.children = nextChildren
  return target
}
