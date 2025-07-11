import router from '@ohos.router';
import prompt from '@ohos.promptAction';
import Delegate from '../common/Delegate';
import ChatPresenter from '../common/Presenter'
import { NERtcVideoView, NERtcConstants} from '@nertc/nertc_sdk';
import * as model from '../common/Model';
import fs from '@ohos.file.fs';
import type resourceManager from '@ohos.resourceManager';

@Entry
@Component
struct AudioMixing {

  TAG: string = "AudioMixing"
  chat?: ChatPresenter
  @State cname: string = ""
  @State uid: string = ""
  @State local?: model.User = undefined
  @State login: model.LoginInfo = {
    cname: "1392",
    uid: Math.floor(Math.random() * 10000).toString()
  };
  @State remoteUser1?: model.User = undefined
  @State remoteUser2?: model.User = undefined
  @State remoteUser3?: model.User = undefined
  @State remoteUser4?: model.User = undefined

  remoteUserList: bigint[] = []

  onPageShow() {
    console.info(this.TAG, '=== CallPage show ===')
    ChatPresenter.getInstance().setDelegate(this.delegate)
    this.local = { uid: BigInt(this.login?.uid ?? 0) }
    this.chat = ChatPresenter.getInstance()
    this.checkResource()
    this.init(this.login)
    this.beforeJoin()
    this.joinRoom()
  }
  onPageHide(): void {
    ChatPresenter.getInstance().leave()
    ChatPresenter.getInstance().removeDelegate(this.delegate)
    ChatPresenter.getInstance().release()
  }
  checkResource() {
    this.checkResourceWithName("mozart.mp3")
    this.checkResourceWithName("yifei.m4a")
  }
  checkResourceWithName(fileName: string) {
    let path: string = getContext(this).filesDir + fileName;
    if (!fs.accessSync(path)) {
      getContext(this).resourceManager.getRawFileContent(fileName).then(data => {
        fs.createStreamSync(path, 'w').writeSync(data.buffer)
      })
    }
  }
  init(login: model.LoginInfo) {
    ChatPresenter.getInstance().init(getContext())
  }
  beforeJoin() {
    ChatPresenter.getInstance().enableVideo(true)
    ChatPresenter.getInstance().enableAudio(true)
  }
  joinRoom() {
    ChatPresenter.getInstance().join(this.login)
  }
  delegate: Delegate = {
    onJoin: (result: number, channelId: bigint): void => {
      prompt.showToast({ message: 'Join channel async result:' + result, duration: 2000 })
    },
    onLeave: (result: number): void =>{

    },
    onUserJoin:(uid: bigint): void => {
      if(this.findFalseIndex(uid) != -1){
        return
      }
      this.remoteUserList.push(uid);
      if(this.remoteUser1 == undefined) {
        this.remoteUser1 = { uid: uid }
        console.info(this.TAG, 'Create Remote User1.')
      }else if(this.remoteUser2 == undefined) {
        this.remoteUser2 = { uid: uid }
        console.info(this.TAG, 'Create Remote User2.')
      }else if(this.remoteUser3 == undefined) {
        this.remoteUser3 = { uid: uid }
        console.info(this.TAG, 'Create Remote User3.')
      }else if(this.remoteUser4 == undefined){
        this.remoteUser4 = { uid: uid }
        console.info(this.TAG, 'Create Remote User4.')
      }
    },
    onUserLeave:(uid: bigint, reason: number): void => {
      if(this.findFalseIndex(uid) == -1){
        return
      }
      this.remoteUserList.splice(this.findFalseIndex(uid), 1);
      if(this.remoteUser1 && this.remoteUser1.uid === uid) {
        this.remoteUser1 = undefined
      }else if(this.remoteUser2 && this.remoteUser2.uid === uid) {
        this.remoteUser2 = undefined
      }else if(this.remoteUser3 && this.remoteUser3.uid === uid) {
        this.remoteUser3 = undefined
      }else if(this.remoteUser4 && this.remoteUser4.uid === uid){
        this.remoteUser4 = undefined
      }
    },
    onUserAudioStart:(uid: bigint): void =>{

    },
    onUserAudioStop:(uid: bigint): void =>{

    },
    onUserVideoStart:(uid: bigint): void =>{

    },
    onUserVideoStop:(uid: bigint): void =>{

    }

  };
  findFalseIndex(uid: bigint) {
    let index = -1
    for (let i = 0; i < this.remoteUserList.length; i++) {
      if (this.remoteUserList[i] == uid) {
        index = i
        break
      }
    }
    return index
  }
  build() {
    Row() {
      Column() {
        Text('房间号: ' + this.cname)
          .width('100%')
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .margin({ top: "20vp", bottom: "20vp" })
        Row() {
          if (this.local) {
            NERtcVideoView({
              canvasId: String(this.local.uid),
              onLoad: (() => {
                console.info(this.TAG, `User: ${this.local?.uid} surface create.`)
                if (this.local) this.chat?.attach(this.local)
              }),
              onDestroy: (() => {
                console.info(this.TAG, `User: ${this.local?.uid} surface release.`)
              })
            }).width('100%').height('40%')
          }
        }
        Row() {
          if (this.remoteUser1) {
            NERtcVideoView({
              canvasId: String(this.remoteUser1.uid),
              onLoad: (() => {
                if (this.remoteUser1) {
                  console.info(this.TAG, `User: ${String(this.remoteUser1?.uid)} surface create.`)
                  this.chat?.attach(this.remoteUser1)
                }
              }),
              onDestroy: (() => {
                if (this.remoteUser1) {
                  console.info(this.TAG, `User: ${String(this.remoteUser1?.uid)} surface release.`)
                }
              })
            }).width('25%').height('20%')
          }else{
            Image($r('app.media.common_user_portrait'))
              .width("25%")
              .objectFit(ImageFit.Contain).margin(15)
              .margin({ top: "10vp", bottom: "40vp" })
          }
          if (this.remoteUser2) {
            NERtcVideoView({
              canvasId: String(this.remoteUser2.uid),
              onLoad: (() => {
                if (this.remoteUser2) {
                  console.info(this.TAG, `User: ${String(this.remoteUser2?.uid)} surface create.`)
                  this.chat?.attach(this.remoteUser2)
                }
              }),
              onDestroy: (() => {
                if (this.remoteUser2) {
                  console.info(this.TAG, `User: ${String(this.remoteUser2?.uid)} surface release.`)
                }
              })
            }).width('25%').height('20%')
          }else{
            Image($r('app.media.common_user_portrait'))
              .width("25%")
              .objectFit(ImageFit.Contain).margin(15)
              .margin({ top: "10vp", bottom: "40vp" })
          }
          if (this.remoteUser3) {
            NERtcVideoView({
              canvasId: String(this.remoteUser3.uid),
              onLoad: (() => {
                if (this.remoteUser3) {
                  console.info(this.TAG, `User: ${String(this.remoteUser3?.uid)} surface create.`)
                  this.chat?.attach(this.remoteUser3)
                }
              }),
              onDestroy: (() => {
                if (this.remoteUser3) {
                  console.info(this.TAG, `User: ${String(this.remoteUser3?.uid)} surface release.`)
                }
              })
            }).width('25%').height('20%')
          }else{
            Image($r('app.media.common_user_portrait'))
              .width("25%")
              .objectFit(ImageFit.Contain).margin(15)
              .margin({ top: "10vp", bottom: "40vp" })
          }
          if (this.remoteUser4) {
            NERtcVideoView({
              canvasId: String(this.remoteUser4.uid),
              onLoad: (() => {
                if (this.remoteUser4) {
                  console.info(this.TAG, `User: ${String(this.remoteUser4?.uid)} surface create.`)
                  this.chat?.attach(this.remoteUser4)
                }
              }),
              onDestroy: (() => {
                if (this.remoteUser4) {
                  console.info(this.TAG, `User: ${String(this.remoteUser4?.uid)} surface release.`)
                }
              })
            }).width('25%').height('20%')
          }else{
            Image($r('app.media.common_user_portrait'))
              .width("25%")
              .objectFit(ImageFit.Contain).margin(15)
              .margin({ top: "10vp", bottom: "40vp" })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        Row() {
          Text('请选择音乐： ')
            .width('100%')
            .fontSize(15)
            .textAlign(TextAlign.Start)
            .margin({ top: "5vp", bottom: "5vp" })
        }
        .justifyContent(FlexAlign.Start)
        Row() {
          Button("开始音乐1", { type: ButtonType.Capsule, stateEffect: true})
            .onClick(() => {
              let option : NERtcConstants.NERtcCreateAudioMixingOption = new NERtcConstants.NERtcCreateAudioMixingOption;
              option.path = "http://mpge.5nd.com/2015/2015-11-26/69708/1.mp3"
              ChatPresenter.getInstance().startAudioMixing(option)
            })
            .margin(10)
          Button("开始音乐2", { type: ButtonType.Capsule, stateEffect: true})
            .onClick(() => {
              let option : NERtcConstants.NERtcCreateAudioMixingOption = new NERtcConstants.NERtcCreateAudioMixingOption;
              let filePath = getContext(this).filesDir + "mozart.mp3";
              if(fs.accessSync(filePath)) {
                option.path = filePath
                ChatPresenter.getInstance().startAudioMixing(option)
              }
            })
            .margin(10)
          Button("开始音乐3", { type: ButtonType.Capsule, stateEffect: true})
            .onClick(() => {
              let option : NERtcConstants.NERtcCreateAudioMixingOption = new NERtcConstants.NERtcCreateAudioMixingOption;
              let filePath = getContext(this).filesDir + "yifei.m4a";
              if(fs.accessSync(filePath)) {
                option.path = filePath
                ChatPresenter.getInstance().startAudioMixing(option)
              }
            })
            .margin(10)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center).width('100%').margin({ top: 20 }).height(80)
        Row() {
          Button("暂停", { type: ButtonType.Capsule, stateEffect: true})
            .onClick(() => {
              ChatPresenter.getInstance().pauseAudioMixing()
            })
            .margin(10)
          Button("恢复", { type: ButtonType.Capsule, stateEffect: true})
            .onClick(() => {
              let ret = ChatPresenter.getInstance().resumeAudioMixing()
            })
            .margin(10)
          Button("停止", { type: ButtonType.Capsule, stateEffect: true})
            .onClick(() => {
              ChatPresenter.getInstance().stopAudioMixing()
            })
            .margin(10)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center).width('100%').margin({ top: 20 }).height(80)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
  }

}