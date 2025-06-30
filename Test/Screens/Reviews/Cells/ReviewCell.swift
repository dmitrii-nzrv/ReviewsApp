import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void
    /// Имя пользователя
    let userName: String?
    /// Рейтинг
    let userRating: Int?

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.config = self
        // Имя пользователя
        cell.nameLabel.text = userName
        // Рейтинг
        if let rating = userRating {
            let renderer = RatingRenderer()
            cell.ratingImageView.image = renderer.ratingImage(rating)
        } else {
            cell.ratingImageView.image = nil
        }
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let avatarImage = UIImageView()
    fileprivate let nameLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImage.frame = layout.avatarFrame
        nameLabel.frame = layout.nameLabelFrame
        ratingImageView.frame = layout.ratingImageViewFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        setupAvatarImage()
        setupNameLabel()
        setupRatingImageView()
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
    }
    
    func setupAvatarImage() {
        contentView.addSubview(avatarImage)
        avatarImage.image = UIImage(named: "l5w5aIHioYc")
        avatarImage.layer.cornerRadius = 18
        avatarImage.clipsToBounds = true
        avatarImage.contentMode = .scaleAspectFill
    }

    func setupNameLabel() {
        contentView.addSubview(nameLabel)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
    }

    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
    }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0

    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var createdAvatarImageFrame = CGRect.zero
    private(set) var avatarFrame = CGRect.zero
    private(set) var nameLabelFrame = CGRect.zero
    private(set) var ratingImageViewFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right
        // Аватар
        avatarFrame = CGRect(origin: CGPoint(x: insets.left, y: insets.top), size: Self.avatarSize)
        // Имя + рейтинг: вертикальное центрирование относительно аватара
        let nameHeight: CGFloat = 18
        let ratingHeight: CGFloat = 18
        let blockHeight = nameHeight + usernameToRatingSpacing + ratingHeight
        let blockY = insets.top + (Self.avatarSize.height - blockHeight) / 2
        let nameX = avatarFrame.maxX + avatarToUsernameSpacing
        let nameY = blockY
        let nameSize = CGSize(width: width - Self.avatarSize.width - avatarToUsernameSpacing, height: nameHeight)
        nameLabelFrame = CGRect(origin: CGPoint(x: nameX, y: nameY), size: nameSize)
        let ratingY = nameLabelFrame.maxY + usernameToRatingSpacing
        let ratingSize = CGSize(width: 100, height: ratingHeight)
        ratingImageViewFrame = CGRect(origin: CGPoint(x: nameX, y: ratingY), size: ratingSize)
        // Текст
        let textY = max(avatarFrame.maxY, ratingImageViewFrame.maxY) + ratingToTextSpacing
        let contentLeft = nameLabelFrame.origin.x
        let contentWidth = maxWidth - contentLeft - insets.right
        var currentTextHeight: CGFloat = 0
        if !config.reviewText.isEmpty() {
            currentTextHeight = (config.reviewText.font() ?? UIFont.systemFont(ofSize: 15)).lineHeight * CGFloat(config.maxLines)
        }
        let textSize: CGSize = !config.reviewText.isEmpty() ? config.reviewText.boundingRect(width: contentWidth, height: currentTextHeight).size : .zero
        reviewTextLabelFrame = CGRect(origin: CGPoint(x: contentLeft, y: textY), size: textSize)
        var maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        let actualTextHeight: CGFloat = !config.reviewText.isEmpty() ? config.reviewText.boundingRect(width: contentWidth).size.height : 0
        let showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight
        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: contentLeft, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }
        createdLabelFrame = CGRect(
            origin: CGPoint(x: contentLeft, y: maxY),
            size: config.created.boundingRect(width: contentWidth).size
        )
        return createdLabelFrame.maxY + insets.bottom
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout

final class ReviewsCountCell: UITableViewCell {
    static let reuseId = "ReviewsCountCell"
    let countLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        countLabel.textAlignment = .center
        countLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        countLabel.textColor = .secondaryLabel
        contentView.addSubview(countLabel)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        countLabel.frame = contentView.bounds
    }
}
