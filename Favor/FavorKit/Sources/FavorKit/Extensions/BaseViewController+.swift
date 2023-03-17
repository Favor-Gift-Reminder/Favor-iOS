//
//  BaseViewController+.swift
//  
//
//  Created by 김응철 on 2023/03/17.
//

import UIKit

import RxSwift

private var spinnerView: UIView?

extension Reactive where Base: BaseViewController {
  
  public var isLoading: Binder<Bool> {
    return Binder(self.base) { vc, isLoading in
      let spinner = UIActivityIndicatorView()
      spinner.color = .lightGray
      
      if isLoading {
        guard spinnerView == nil else { return }
        spinnerView = UIView(frame: vc.view.bounds)
        spinnerView?.backgroundColor = .clear
        spinnerView?.addSubview(spinner)
        spinner.center = spinnerView!.center
        spinner.startAnimating()
        vc.view.addSubview(spinnerView!)
      } else {
        guard spinnerView != nil else { return }
        spinnerView?.removeFromSuperview()
        spinnerView = nil
      }
    }
  }
}
