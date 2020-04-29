//
//  CameraController.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 28.04.2020.
//

import Foundation
import UIKit
import Library
import AVFoundation

public final class CameraController: BaseController<CameraRootView> {
	private lazy var session = AVCaptureSession()

	override func setup() {
		super.setup()

		navigationItem.title = "Camera"
		tabBarItem.title = "Camera"
		tabBarItem.image = UIImage(systemName: "camera")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		guard
			let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back),
			let input = try? AVCaptureDeviceInput(device: videoDevice),
			session.canAddInput(input)
		else { return }


		session.addInput(input)

		typedView.set(session: session)

		session.startRunning()
	}
}
