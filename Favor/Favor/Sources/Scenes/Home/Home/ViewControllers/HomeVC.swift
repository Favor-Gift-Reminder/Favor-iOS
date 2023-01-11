//
//  HomeVC.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

import ReactorKit
import RxSwift
import SnapKit
import Then

final class HomeViewController: BaseViewController, View {
	typealias Reactor = HomeReactor
	
	// MARK: - Properties
	
	// MARK: - Setup
	
	override func setupStyles() {
		self.view.backgroundColor =  .systemBackground
	}
	
	// MARK: - Binding
	
	func bind(reactor: HomeReactor) {
		//
	}
	
}
