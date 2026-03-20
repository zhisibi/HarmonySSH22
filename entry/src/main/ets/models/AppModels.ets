export enum AppPage {
  Login = 'Login',
  Home = 'Home',
  ServerForm = 'ServerForm',
  Terminal = 'Terminal',
  Sftp = 'Sftp',
  Settings = 'Settings'
}

export interface UserSession {
  backendUrl: string
  username: string
  loggedIn: boolean
}

export interface ServerItem {
  id: string
  name: string
  host: string
  port: number
  username: string
  remark?: string
}

export interface TerminalLine {
  id: string
  type: 'command' | 'output' | 'info'
  content: string
}

export interface SftpNode {
  name: string
  path: string
  isDirectory: boolean
  size?: string
  children?: SftpNode[]
}
