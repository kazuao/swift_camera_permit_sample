//
//  ViewController.swift
//  CameraPermitSample
//
//  Created by Kazunori Aoki on 2021/04/01.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // デバイス入出力管理オブジェクト
    var captureSession = AVCaptureSession()
    
    // カメラデバイスそのものを管理するオブジェクト
    // メインカメラの管理オブジェクト
    var mainCamera: AVCaptureDevice?
    // インカメ
    var innerCamera: AVCaptureDevice?
    // 現在使用のカメラデバイスの管理
    var currentDevice: AVCaptureDevice?
    
    // キャプチャーの出力データを受け付けるオブジェクト
    var photoOutput: AVCapturePhotoOutput?
    
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleCaptureButton()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
    }
    
    func styleCaptureButton() {
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 5
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
    
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        
        // 起動時のカメラを設定
        currentDevice = mainCamera
    }
    
    // 入出力データの設定
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクト
            photoOutput = AVCapturePhotoOutput()
            // 出力ファイルのフォーマットを指定
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        //指定したAVCaptureSessionでプレビューレイヤーを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤがカメラのキャプチャーを縦横比を維持した状態d表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    @IBAction func tapCameraButton(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        // フラッシュの設定
        if (currentDevice!.isFlashAvailable) {
            settings.flashMode = .auto
        }
        else {
            settings.flashMode = .off
        }
        // カメラの手ブレ補正
        settings.isAutoStillImageStabilizationEnabled = true
        // 撮影された画像をdelegateで処理
        self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        if let imageData = photo.fileDataRepresentation() {
            // Data型をUIImageに変換
            let uiImage = UIImage(data: imageData)
            // 写真をライブラリに保存
            UIImageWriteToSavedPhotosAlbum(uiImage!, nil, nil, nil)
        }
    }
}
