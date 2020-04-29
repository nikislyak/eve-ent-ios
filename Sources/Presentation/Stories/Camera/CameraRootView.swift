//
//  CameraRootView.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 28.04.2020.
//

import Foundation
import Library
import Stevia
import AVFoundation

class CameraView: BaseView {
	override class var layerClass: AnyClass {
		AVCaptureVideoPreviewLayer.self
	}

	var previewLayer: AVCaptureVideoPreviewLayer {
		layer as! AVCaptureVideoPreviewLayer
	}
}

public final class CameraRootView: BaseView {
	private let cameraView = CameraView()

	override func setup() {
		super.setup()

		sv(cameraView)

		cameraView.fillContainer()
	}

	func set(session: AVCaptureSession) {
		cameraView.previewLayer.session = session
	}
}

extension CameraRootView: StateDriven {
	public struct State: EmptyInitializable, Equatable {
		public init() {}
	}

	public func render(_ state: State) {
		
	}
}
