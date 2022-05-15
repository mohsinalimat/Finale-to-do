//
//  UserProfileViewController.swift
//  Finale To-do
//
//  Created by Grant Oganan on 5/4/22.
//

import Foundation
import UIKit


class UserProfileNavigationController: UINavigationController {
    init() {
        super.init(nibName: nil, bundle: nil)
        
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        self.setViewControllers([UserProfileViewController()], animated: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        App.instance.SetSubviewColors(of: self.view)
        SetAllViewControllerColors()
    }
    
    func SetAllViewControllerColors() {
        for viewController in self.viewControllers {
            if let dynamicTheme = viewController as? UIDynamicTheme { dynamicTheme.ReloadThemeColors() }
            for subview in viewController.view.subviews {
                SetSubviewColors(of: subview)
            }
        }
    }
    
    func SetSubviewColors(of view: UIView) {
        if let dynamicThemeView = view as? UIDynamicTheme  {
            dynamicThemeView.ReloadThemeColors()
        }
        
        for subview in view.subviews {
            SetSubviewColors(of: subview)
        }
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: User Profile view controller
class UserProfileViewController: UIViewController, UIDynamicTheme {
    
    let padding = 16.0
    
    var levelFrame: LevelFrame!
    var progressBar: ProgressBar!
    var badgesContainer: UIView!
    var levelPerksContainer: UIView!
    var statisticsContainer: UIView!
    
    init () {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = ThemeManager.currentTheme.settingsBackgroundColor
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration.init(weight: .semibold)), style: .plain, target: self, action: #selector(ShareTap))
        
        let frameWidth = view.frame.width
        let frameHeight = view.frame.height
        
        let handleWidth = frameWidth*0.15
        let handle = UIView(frame: CGRect(x: 0.5*(frameWidth-handleWidth), y: padding*0.5, width: handleWidth, height: 4))
        handle.backgroundColor = .systemGray4
        handle.layer.cornerRadius = 2
        
        let levelFrameSize = 100.0
        levelFrame = LevelFrame(frame: CGRect(x: 0.5*(frameWidth-levelFrameSize), y: handle.frame.maxY + padding*3, width: levelFrameSize, height: levelFrameSize))
        levelFrame.UpdateLevel(level: StatsManager.stats.level)
        
        let nameLabel = UILabel(frame: CGRect(x: padding, y: levelFrame.frame.maxY+padding*1, width: frameWidth-padding*2, height: 50))
        nameLabel.text = App.settingsConfig.userFullName == " " ? "User" : App.settingsConfig.userFullName
        nameLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 40)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        progressBar = ProgressBar(frame: CGRect(x: padding*4, y: nameLabel.frame.maxY+padding, width: frameWidth-padding*8, height: 4))
        progressBar.UpdateProgress(progress: StatsManager.levelProgress)
        
        let progressLabel = UILabel(frame: CGRect(x: padding*4, y: progressBar.frame.maxY+padding*0.5, width: frameWidth-padding*8, height: 18))
        progressLabel.text = "\(StatsManager.pointsLeftToNextLevel) points to level \(StatsManager.stats.level + 1)"
        progressLabel.font = .preferredFont(forTextStyle: .footnote)
        progressLabel.textAlignment = .center
        progressLabel.textColor = .systemGray
        
        badgesContainer = DrawBadgesBox(frame: CGRect(x: padding, y: progressLabel.frame.maxY + padding*2, width: frameWidth-padding*2, height: 120))
        
        levelPerksContainer = DrawRow(frame: CGRect(x: padding, y: badgesContainer.frame.maxY + padding, width: frameWidth-padding*2, height: 46), title: "My Level Perks")
        let levelPerksTap = UILongPressGestureRecognizer(target: self, action: #selector(MyLevelPerksTap))
        levelPerksTap.minimumPressDuration = 0
        levelPerksContainer.addGestureRecognizer(levelPerksTap)
        
        statisticsContainer = DrawRow(frame: CGRect(x: padding, y: levelPerksContainer.frame.maxY + padding, width: frameWidth-padding*2, height: 46), title: "My Statistics")
        let statTap = UILongPressGestureRecognizer(target: self, action: #selector(MyStatisticsTap))
        statTap.minimumPressDuration = 0
        statisticsContainer.addGestureRecognizer(statTap)
        
        self.view.addSubview(handle)
        self.view.addSubview(levelFrame)
        self.view.addSubview(nameLabel)
        self.view.addSubview(progressBar)
        self.view.addSubview(progressLabel)
        self.view.addSubview(badgesContainer)
        self.view.addSubview(levelPerksContainer)
        self.view.addSubview(statisticsContainer)
    }
    
    func DrawBadgesBox(frame: CGRect) -> UIView {
        let containerView = UIView(frame: CGRect(origin: frame.origin, size: frame.size))
        containerView.layer.cornerRadius = 12
        containerView.backgroundColor = ThemeManager.currentTheme.settingsRowBackgroundColor
        
        let titleLabel = UILabel(frame: CGRect(x: padding, y: padding*0.8, width: containerView.frame.width*0.8, height: 20))
        titleLabel.text = "My Badges"
        
        let iconSize = 14.0
        let openIcon = UIImageView(frame: CGRect(x: containerView.frame.width-padding*0.5-iconSize, y: 0.5*(titleLabel.frame.origin.y + iconSize), width: iconSize*0.7, height: iconSize))
        openIcon.image = UIImage(systemName: "greaterthan")
        openIcon.tintColor = .systemGray2
        
        let scrollViewHeight = containerView.frame.height-titleLabel.frame.maxY
        let cellSize = scrollViewHeight-padding*2
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: titleLabel.frame.maxY, width: containerView.frame.width, height: scrollViewHeight))
        
        let badgesSpacing = padding*0.5
        var i = 0
        for (groupID, badgeIndex) in StatsManager.stats.badges {
            if badgeIndex == -1 { continue }
            
            let badgeCell = UIImageView(frame: CGRect(x: padding+(cellSize+badgesSpacing)*Double(i), y: padding, width: cellSize, height: cellSize))
            badgeCell.image = StatsManager.getBadgeGroup(id: groupID)?.getIcon(index: badgeIndex)
            badgeCell.contentMode = .scaleAspectFit
            badgeCell.layer.shadowRadius = 3
            badgeCell.layer.shadowOffset = CGSize.zero
            badgeCell.layer.shadowColor = UIColor.black.cgColor
            badgeCell.layer.shadowOpacity = ThemeManager.currentTheme.interface == .Light ? 0.2 : 1
            scrollView.addSubview(badgeCell)
            i += 1
        }
        
        scrollView.contentSize.width = padding + (cellSize+badgesSpacing)*Double(i)
        
        if i == 0 {
            let placeholderLabel = UILabel(frame: CGRect(x: padding, y: padding*2+titleLabel.frame.height, width: frame.width-padding*2, height: containerView.frame.height-padding*3-titleLabel.frame.height))
            placeholderLabel.text = "You don't have any badges yet"
            placeholderLabel.textColor = .systemGray2
            containerView.addSubview(placeholderLabel)
        }
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(openIcon)
        containerView.addSubview(scrollView)
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(MyBadgesTap))
        tap.minimumPressDuration = 0
        containerView.addGestureRecognizer(tap)
        
        return containerView
    }
    
    func DrawRow(frame: CGRect, title: String) -> UIView {
        let containerView = UIView(frame: CGRect(origin: frame.origin, size: frame.size))
        containerView.layer.cornerRadius = 12
        containerView.backgroundColor = ThemeManager.currentTheme.interface == .Light ? .white : .systemGray6
        
        let titleLabel = UILabel(frame: CGRect(x: padding, y: 0, width: containerView.frame.width*0.8, height: frame.height))
        titleLabel.text = title
        
        let iconSize = 14.0
        let openIcon = UIImageView(frame: CGRect(x: containerView.frame.width-padding*0.5-iconSize, y: 0.5*(frame.height - iconSize), width: iconSize*0.7, height: iconSize))
        openIcon.image = UIImage(systemName: "greaterthan")
        openIcon.tintColor = .systemGray2
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(openIcon)
        
        return containerView
    }
    
    @objc func ShareTap () {
        self.navigationController!.show(ShareModalViewController(), sender: self.navigationController)
    }
    
    @objc func MyBadgesTap (sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            badgesContainer.backgroundColor = .systemGray5
        } else if sender.state == .ended {
            self.navigationController!.show(MyBadgesViewController(), sender: self.navigationController)
            UIView.animate(withDuration: 0.25) { [self] in
                badgesContainer.backgroundColor = ThemeManager.currentTheme.settingsRowBackgroundColor
            }
        }
    }
    
    @objc func MyLevelPerksTap (sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            levelPerksContainer.backgroundColor = .systemGray5
        } else if sender.state == .ended {
            self.navigationController!.show(MyLevelPerksController(), sender: self.navigationController)
            UIView.animate(withDuration: 0.25) { [self] in
                levelPerksContainer.backgroundColor = ThemeManager.currentTheme.settingsRowBackgroundColor
            }
        }
    }
    
    @objc func MyStatisticsTap (sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            statisticsContainer.backgroundColor = .systemGray5
        } else if sender.state == .ended {
            self.navigationController!.show(SettingsStatisticsPage(), sender: self.navigationController)
            UIView.animate(withDuration: 0.25) { [self] in
                statisticsContainer.backgroundColor = ThemeManager.currentTheme.settingsRowBackgroundColor
            }
        }
        
    }
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            badgesContainer.backgroundColor = ThemeManager.currentTheme.settingsRowBackgroundColor
            levelPerksContainer.backgroundColor = ThemeManager.currentTheme.settingsRowBackgroundColor
            statisticsContainer.backgroundColor = ThemeManager.currentTheme.settingsRowBackgroundColor
            self.view.backgroundColor = ThemeManager.currentTheme.settingsBackgroundColor
            levelFrame.UpdateColor(color: ThemeManager.currentTheme.primaryElementColor())
            progressBar.ReloadColors()
        }
    }
    
    
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



//MARK: My Badges view controller
class MyBadgesViewController: UIViewController {
    
    let padding = 16.0
    
    init () {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .systemGray6
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        self.title = "My Badges"
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let nColumns = 3
        let rows = (Double(StatsManager.allBadgeGroups.count) / Double(nColumns))
        let nRows = Int(rows.rounded(.up))
        let cellWidth = ((width-padding*4)/3)
        let cellHeight = cellWidth + padding*1.5 + 50
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        scrollView.contentSize.height = (cellHeight+padding)*Double(nRows)
        
        for row in 0..<nRows {
            for column in 0..<nColumns {
                let index = column + row*nColumns
                if index < StatsManager.allBadgeGroups.count {
                    let badgeCell = DrawBadgeCell(
                        frame: CGRect(x: padding + (cellWidth+padding)*Double(column), y: (padding+cellHeight)*Double(row), width: cellWidth, height: cellHeight),
                        badgeGroupIndex: index,
                        lastUnlockedIndex: StatsManager.stats.lastUnlockedBadgeIndex(badgeGroupID: index))
                    scrollView.addSubview(badgeCell)
                } else {
                    break
                }
            }
        }
        
        self.view.addSubview(scrollView)
    }
    
    func DrawBadgeCell (frame: CGRect, badgeGroupIndex: Int, lastUnlockedIndex: Int) -> UIView {
        let imageSize = frame.size.width
        let badgeGroup = StatsManager.allBadgeGroups[badgeGroupIndex]
        let view = UIView(frame: frame)
        
        let imageView = UIImageView(frame: CGRect(x: 0.5*(frame.width-imageSize), y: 0, width: imageSize, height: imageSize))
        imageView.image = lastUnlockedIndex == -1 ? badgeGroup.getPlaceholder(index: 0) : badgeGroup.getIcon(index: lastUnlockedIndex)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowRadius = lastUnlockedIndex == -1 ? 0 : 7
        imageView.layer.shadowOffset = CGSize.zero
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = ThemeManager.currentTheme.interface == .Light ? 0.3 : 1
        let tap = UITapGestureRecognizer(target: self, action: #selector(BadgeTap))
        tap.name = badgeGroupIndex.description
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        
        let titleLable = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY+padding, width: frame.width, height: 20))
        titleLable.text = badgeGroup.getName(index: lastUnlockedIndex == -1 ? 0 : lastUnlockedIndex)
        titleLable.textAlignment = .center
        titleLable.adjustsFontSizeToFitWidth = true
        
        let descriptionLabel = UILabel(frame: CGRect(x: 0, y: titleLable.frame.maxY+padding*0.5, width: frame.width, height: 30))
        descriptionLabel.text = badgeGroup.getDescription(index: lastUnlockedIndex == -1 ? 0 : lastUnlockedIndex)
        descriptionLabel.textAlignment = .center
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 12)
        descriptionLabel.textColor = .systemGray
        descriptionLabel.sizeToFit()
        descriptionLabel.frame.origin.x = 0.5*(frame.width - descriptionLabel.frame.width)
        
        view.addSubview(imageView)
        view.addSubview(titleLable)
        view.addSubview(descriptionLabel)
        
        return view
    }
    
    @objc func BadgeTap (sender: UITapGestureRecognizer) {
        self.navigationController!.show(BadgeGroupViewController(badgeGroup: StatsManager.allBadgeGroups[Int(sender.name!)!]), sender: self.navigationController)
    }
                                       
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: Badge Group view controller
class BadgeGroupViewController: UIViewController, UIScrollViewDelegate {
    
    let padding = 16.0
    
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let pageControl = UIPageControl()
    
    var currentPage = 0
    
    let badgeGroup: AchievementBadgeGroup
    
    init (badgeGroup: AchievementBadgeGroup) {
        self.badgeGroup = badgeGroup
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .systemGray6
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        self.title = "My Badges"
        self.view.clipsToBounds = true
        
        let lastUnlockedIndex = StatsManager.stats.lastUnlockedBadgeIndex(badgeGroupID: badgeGroup.groupID)
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let nBadges = badgeGroup.numberOfBadges
        let cellWidth = width*0.7
        let cellHeight = cellWidth
        let fullHeight = cellHeight+padding*4+70
        let scrollView = UIScrollView(frame: CGRect(x: 0.5*(width-cellWidth), y: 0.4*(UIScreen.main.bounds.height-fullHeight), width: cellWidth, height: cellHeight))
        scrollView.contentSize.width = cellWidth*Double(nBadges)
        scrollView.isPagingEnabled = true
        scrollView.clipsToBounds = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        for i in 0..<nBadges {
            let cell = DrawBadgeCell(
                frame: CGRect(x: Double(i)*cellWidth, y: 0, width: cellWidth, height: cellHeight),
                badgeGroup: badgeGroup,
                index: i,
                isUnlocked: i <= lastUnlockedIndex)
            scrollView.addSubview(cell)
        }
        self.view.addSubview(scrollView)
        
        titleLabel.frame = CGRect(x: padding, y: scrollView.frame.maxY+padding, width: width-padding*2, height: 30)
        titleLabel.text = badgeGroup.getName(index: currentPage)
        titleLabel.font = .systemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        
        descriptionLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY+padding, width: width-padding*2, height: 20)
        descriptionLabel.text = getDescription(index: currentPage)
        descriptionLabel.font = .systemFont(ofSize: 18)
        descriptionLabel.textColor = .systemGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.adjustsFontSizeToFitWidth = true
        
        pageControl.frame = CGRect(x: padding, y: descriptionLabel.frame.maxY + padding*2, width: width-padding*2, height: 20)
        pageControl.numberOfPages = nBadges
        pageControl.currentPage = currentPage
        pageControl.backgroundStyle = .prominent
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(pageControl)
    }
    
    func DrawBadgeCell (frame: CGRect, badgeGroup: AchievementBadgeGroup, index: Int, isUnlocked: Bool) -> UIView {
        let imageSize = frame.size.width*0.95
        
        let view = UIView(frame: frame)
        
        let imageView = UIImageView(frame: CGRect(x: 0.5*(frame.width-imageSize), y: 0.5*(frame.height-imageSize), width: imageSize, height: imageSize))
        imageView.image = isUnlocked ? badgeGroup.getIcon(index: index) : badgeGroup.getPlaceholder(index: index)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowRadius = isUnlocked ? 15 : 0
        imageView.layer.shadowOffset = CGSize.zero
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = ThemeManager.currentTheme.interface == .Light ? 0.3 : 1
        
        view.addSubview(imageView)
        
        return view
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = max(0, min(badgeGroup.numberOfBadges-1, Int((scrollView.contentOffset.x / scrollView.frame.width).rounded())))
        
        pageControl.currentPage = currentPage
        titleLabel.text = badgeGroup.getName(index: currentPage)
        descriptionLabel.text = getDescription(index: currentPage)
    }
    
    func getDescription (index: Int) -> String {
        if index <= StatsManager.stats.lastUnlockedBadgeIndex(badgeGroupID: badgeGroup.groupID) { return badgeGroup.getDescription(index: currentPage) }
        
        return "\(badgeGroup.getDescription(index: currentPage)) (\(badgeGroup.relatedStat())/\(badgeGroup.unlockStatValue[currentPage]))"
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}









//MARK: My Level Pekrs
class MyLevelPerksController: UIViewController, UIDynamicTheme, UITableViewDelegate, UITableViewDataSource {
    
    let padding = 16.0
    
    var tableView: UITableView?
    
    init () {
        super.init(nibName: nil, bundle: nil)
        
        if !StatsManager.stats.purchasedUnlockAllPerks && StatsManager.stats.level < StatsManager.allLevelPerks.last!.unlockLevel  {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unlock All", style: .plain, target: self, action: #selector(TapUnlockAll))
        }
        
        self.view.backgroundColor = ThemeManager.currentTheme.settingsBackgroundColor
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        self.title = "My Level Perks"
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: width, height: height), style: .insetGrouped)
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView!.bounds.size.width, height: .leastNonzeroMagnitude))
        tableView!.backgroundColor = ThemeManager.currentTheme.interface == .Light ? .systemGray6 : .black
        
        self.view.addSubview(tableView!)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return StatsManager.allLevelPerks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Level \(StatsManager.allLevelPerks[section].unlockLevel)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SettingsTableCell()
        cell.Setup(settingsOption: .selectionCell(model: SettingsSelectionOption(
            title: StatsManager.allLevelPerks[indexPath.section].title,
            selectionID: 0,
            isSelected: StatsManager.allLevelPerks[indexPath.section].isUnlocked,
            OnSelect: {})))
        cell.selectionStyle = StatsManager.allLevelPerks[indexPath.section].type == .TrueBlackTheme || StatsManager.allLevelPerks[indexPath.section].type == .ColoredAppIcons ? .default : .none
        cell.accessoryType = StatsManager.allLevelPerks[indexPath.section].type == .TrueBlackTheme || StatsManager.allLevelPerks[indexPath.section].type == .ColoredAppIcons ? .disclosureIndicator : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 || indexPath.section == 1 {
            self.show(SettingsAppearancePage(), sender: nil)
        }
    }
    
    
    func ReloadThemeColors() {
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        UIView.animate(withDuration: 0.25) { [self] in
            self.view.backgroundColor = ThemeManager.currentTheme.settingsBackgroundColor
            tableView?.backgroundColor = ThemeManager.currentTheme.interface == .Light ? .systemGray6 : .black
            if tableView != nil {
                for cell in tableView!.visibleCells {
                    let c = cell as! SettingsTableCell
                    c.ReloadThemeColors()
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        App.instance.SetSubviewColors(of: self.view)
        ReloadThemeColors()
    }
    
    @objc func TapUnlockAll() {
        self.navigationController!.show(UnlockAllLevelPerksViewController(), sender: self.navigationController)
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


//MARK: Share Modal
class ShareModalViewController: UIViewController {
    
    let padding = 16.0
    
    var shareModal: UIView!
    var shareImage: UIImage!
    
    var anonymusNames = ["Anonymous Peacock", "Anonymous Cormorant", "Anonymous Froggy", "Anonymous Shark", "Anonymous Bull", "Anonymous Buffalo", "Anonymous Parrot", "Anonymous Lynx", "Anonymous Bobcat", "Anonymous Lizard", "Anonymous Raptor", "Anonymous Lion", "Anonymous Puma", "Anonymous Gazzelle", "Anonymous Zebra"]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = ThemeManager.currentTheme.settingsBackgroundColor
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        let modalWidth: CGFloat = UIScreen.main.bounds.width - padding*4
        let modalHeight: CGFloat = modalWidth*1.33
        
        shareModal = DrawShareModalImage(frame: CGRect(x: padding*2, y: padding*5, width: modalWidth, height: modalHeight))
        shareImage = shareModal.renderImage()
        
        shareModal.layer.cornerRadius = UIScreen.main.bounds.width*0.041
        shareModal.clipsToBounds = true
        
        let frameWidth = self.view.frame.width
        let frameHeight = self.view.frame.height
        let bottomPadding = UIApplication.shared.windows.first!.safeAreaInsets.bottom
        let buttonSize = 40.0
        
        let shareButton = UIButton(frame: CGRect(x: padding, y: frameHeight - bottomPadding - buttonSize*3, width: frameWidth-padding*2, height: buttonSize))
        shareButton.backgroundColor = .defaultColor
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        shareButton.layer.cornerRadius = 8
        shareButton.addTarget(self, action: #selector(Share), for: .touchUpInside)
        shareButton.titleLabel!.font = .Rubik(size: 18)
        
        self.view.addSubview(shareModal)
        self.view.addSubview(shareButton)
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func DrawShareModalImage (frame: CGRect) -> UIView {
        let modalPadding = UIScreen.main.bounds.width*0.041
        
        let width = frame.width
        let height = frame.height
        let innerWidth = frame.width*0.743
        let innerHeight = frame.height*0.719
        
        let background = UIImageView(frame: frame)
        background.image = UIImage(named: "Sharing Modal Background")
        background.contentMode = .scaleAspectFill
        
        let levelFrameSize = background.frame.width*0.35
        let levelFrame = LevelFrame(frame: CGRect(x: 0.5*(width-levelFrameSize), y: height*0.16, width: levelFrameSize, height: levelFrameSize))
        levelFrame.UpdateLevel(level: StatsManager.stats.level)
        levelFrame.UpdateColor(color: .defaultColor)
        
        let raysSize = levelFrameSize*1.4
        let raysView = UIImageView(frame: CGRect(x: levelFrame.frame.origin.x + 0.5*(levelFrameSize-raysSize), y: levelFrame.frame.origin.y + 0.5*(levelFrameSize-raysSize), width: raysSize, height: raysSize))
        raysView.image = UIImage(named: "Sharing Rays")
        raysView.contentMode = .scaleAspectFill
        
        let nameLabel = UILabel(frame: CGRect(x: 0.5*(width-(innerWidth-modalPadding*2)), y: levelFrame.frame.maxY+modalPadding, width: innerWidth-modalPadding*2, height: innerHeight*0.11))
        nameLabel.text = nameText
        nameLabel.font = .Rubik(weight: .regular, size: nameLabel.frame.height*0.8)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        
        var i = 0
        let badgeSize = innerWidth*0.075
        let badgeSpacing = badgeSize*0.15
        let badgesRow = UIView(frame: CGRect(x: 0.5*(width-innerWidth), y: nameLabel.frame.maxY+modalPadding*0.5, width: 0, height: badgeSize))
        for (groupID, badgeIndex) in StatsManager.stats.badges {
            if badgeIndex == -1 { continue }
            
            let badgeCell = UIImageView(frame: CGRect(x: badgeSpacing+(badgeSize+badgeSpacing)*Double(i), y: 0, width: badgeSize, height: badgeSize))
            badgeCell.image = StatsManager.getBadgeGroup(id: groupID)?.getIcon(index: badgeIndex)
            badgeCell.contentMode = .scaleAspectFit
            badgeCell.layer.shadowRadius = 1
            badgeCell.layer.shadowOffset = CGSize.zero
            badgeCell.layer.shadowColor = UIColor.black.cgColor
            badgeCell.layer.shadowOpacity = 0.2
            badgesRow.addSubview(badgeCell)
            i += 1
        }
        badgesRow.frame.size.width = badgeSpacing+(badgeSize+badgeSpacing)*Double(i)
        badgesRow.frame.origin.x = 0.5*(width-badgesRow.frame.width)
        
        let daysJoinedLabel = DrawStatLabel(frame: CGRect(x: 0.5*(width-innerWidth), y: badgesRow.frame.maxY+modalPadding*0.5, width: innerWidth, height: nameLabel.frame.height*0.5), text: daysJoinedText)
        let completedTasksLabel = DrawStatLabel(frame: CGRect(x: 0.5*(width-innerWidth), y: daysJoinedLabel.frame.maxY, width: innerWidth, height: nameLabel.frame.height*0.5), text: completedTasksText)
        let numberOfBadgesLabel = DrawStatLabel(frame: CGRect(x: 0.5*(width-innerWidth), y: completedTasksLabel.frame.maxY, width: innerWidth, height: nameLabel.frame.height*0.5), text: numberOfBadges)
        
        background.addSubview(raysView)
        background.addSubview(levelFrame)
        background.addSubview(nameLabel)
        background.addSubview(badgesRow)
        background.addSubview(daysJoinedLabel)
        background.addSubview(completedTasksLabel)
        background.addSubview(numberOfBadgesLabel)
        
        return background
    }
    
    func DrawStatLabel (frame: CGRect, text: NSMutableAttributedString) -> UILabel {
        let label = UILabel(frame: frame)
        label.attributedText = text
        label.textAlignment = .center
        label.font = .Rubik(size: frame.height*0.8)
        return label
    }
    
    var nameText: String {
        return App.settingsConfig.userFullName == " " ? anonymusNames[Int.random(in: 0..<anonymusNames.count)] : App.settingsConfig.userFullName
    }
    
    var daysJoinedText: NSMutableAttributedString {
        let text = "Joined \(StatsManager.stats.daysAgoJoined) days ago"
        let mutableAttributedString = NSMutableAttributedString.init(string: text)
        
        let fullRange = NSRange(0..<text.count)
        let range = (text as NSString).range(of: " \(StatsManager.stats.daysAgoJoined) ")
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: fullRange)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.defaultColor, range: range)
        return mutableAttributedString
    }
    var completedTasksText: NSMutableAttributedString {
        let text = "Completed \(StatsManager.stats.totalCompletedTasks) tasks"
        let mutableAttributedString = NSMutableAttributedString.init(string: text)
        
        let fullRange = NSRange(0..<text.count)
        let range = (text as NSString).range(of: " \(StatsManager.stats.totalCompletedTasks) ")
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: fullRange)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.defaultColor, range: range)
        return mutableAttributedString
    }
    var numberOfBadges: NSMutableAttributedString {
        let text = "Earned \(StatsManager.stats.numberOfUnlockedBadges) badges"
        let mutableAttributedString = NSMutableAttributedString.init(string: text)
        
        let fullRange = NSRange(0..<text.count)
        let range = (text as NSString).range(of: " \(StatsManager.stats.numberOfUnlockedBadges) ")
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: fullRange)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.defaultColor, range: range)
        return mutableAttributedString
    }
    
    @objc func Share () {
        let items = [shareImage] as [UIImage]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(ac, animated: true, completion: {
            StatsManager.stats.timesSharedProgress += 1
            StatsManager.CheckUnlockedBadge(groupID: 7)
        })
        AnalyticsHelper.LogPressedShareButton()
    }
    
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class UnlockAllLevelPerksViewController: UIViewController {
    
    let padding = 16.0
    
    var purchaseButton: UIButton!
    
    init (showCloseButton: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = ThemeManager.currentTheme.settingsBackgroundColor
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        if showCloseButton {
            let buttonWidth = 80.0
            let closeButtom = UIButton(frame: CGRect(x: self.view.frame.width-padding-buttonWidth, y: padding, width: buttonWidth, height: 30.0))
            closeButtom.setTitle("Close", for: .normal)
            closeButtom.setTitleColor(UIColor.systemBlue, for: .normal)
            closeButtom.titleLabel?.font = .preferredFont(forTextStyle: .headline)
            closeButtom.addTarget(self, action: #selector(CloseButtonTap), for: .touchUpInside)
            closeButtom.contentHorizontalAlignment = .right
            self.view.addSubview(closeButtom)
        }
        
        self.title = "All Perks"
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let imageSize = width*0.5
        let imageView = UIImageView(frame: CGRect(x: 0.5*(width-imageSize), y: padding*6, width: imageSize, height: imageSize))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Unlock All Perks")
        
        let descriptionLabel = UILabel(frame: CGRect(x: padding, y: imageView.frame.maxY + padding*2, width: width-padding*2, height: 0))
        descriptionLabel.text = descriptionText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        descriptionLabel.sizeToFit()
        
        purchaseButton = UIButton(frame: CGRect(x: padding, y: descriptionLabel.frame.maxY + padding*2, width: width-padding*2, height: 45))
        purchaseButton.backgroundColor = ThemeManager.currentTheme.primaryElementColor()
        purchaseButton.setTitle("Unlock all perks", for: .normal)
        purchaseButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        purchaseButton.layer.cornerRadius = 8
        purchaseButton.addTarget(self, action: #selector(UnlockButton), for: .touchUpInside)
        purchaseButton.titleLabel!.font = .Rubik(size: 18)
        
        let restoreButton = UIButton(frame: CGRect(x: padding, y: purchaseButton.frame.maxY, width: width-padding*2, height: 45))
        restoreButton.setTitle("Restore Purchases", for: .normal)
        restoreButton.titleLabel!.font = .Rubik(size: 14)
        restoreButton.setTitleColor(UIColor.label, for: .normal)
        restoreButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        restoreButton.addTarget(self, action: #selector(RestoreButton), for: .touchUpInside)
        
        self.view.addSubview(imageView)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(purchaseButton)
        self.view.addSubview(restoreButton)
    }
    
    var descriptionText: String {
        var text = "Don't want to spend time leveling up? Get access to all perks immediatly for a symbolic price.\n"
        for perk in StatsManager.allLevelPerks {
            text.append("\n- \(perk.title) ")
        }
        return text
    }
    
    @objc func UnlockButton () {
        IAPManager.instance.PurchaseUnlockAllPerks()
    }
    
    @objc func RestoreButton () {
        IAPManager.instance.RestorePurchases()
    }
    
    func ReloadThemeColors() {
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        UIView.animate(withDuration: 0.25) { [self] in
            self.view.backgroundColor = ThemeManager.currentTheme.settingsBackgroundColor
            purchaseButton.backgroundColor = ThemeManager.currentTheme.primaryElementColor()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        App.instance.SetSubviewColors(of: self.view)
        ReloadThemeColors()
    }
    
    @objc func CloseButtonTap () {
        self.dismiss(animated: true)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
