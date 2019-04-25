//
//  WalkthroughVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/22.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

final class WalkthroughVC: UIPageViewController {

    enum VC {
        case aboutThisApp
        case howToImportBirthday
    }
    
    var vcs = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        guard let firstVC = UIStoryboard(name: "AboutThisApp", bundle: nil)
            .instantiateInitialViewController() else { return }
            guard let secondVC = UIStoryboard(name: "AnnivIntroduction", bundle: nil)
                .instantiateInitialViewController() else { return }
            guard let thirdVC = UIStoryboard(name: "GiftIntroduction", bundle: nil)
                .instantiateInitialViewController() else { return }
        
        vcs.append(firstVC)
        vcs.append(secondVC)
        vcs.append(thirdVC)
        
        setViewControllers([vcs.first!], direction: .forward, animated: true, completion: nil)
    }
}

extension WalkthroughVC: UIPageViewControllerDataSource {
    /// 戻る
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        switch viewController {
        case vcs[0]:
            return nil
        case vcs[1]:
            return vcs[0]
        case vcs[2]:
            return vcs[1]
        default:
            return nil
        }
    }
    
    /// 進む
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        switch viewController {
        case vcs[0]:
            return vcs[1]
        case vcs[1]:
            return vcs[2]
        case vcs[2]:
            return nil
        default:
            return nil
        }
    }
}


extension WalkthroughVC: UIPageViewControllerDelegate {
    
    // ページ総数
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return vcs.count
    }
    
    // 最初に表示するページ番号
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
