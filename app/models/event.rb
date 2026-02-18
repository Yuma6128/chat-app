class Event < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  CATEGORIES = {
    'campaign'       => 'キャンペーン',
    'product_launch' => '製品・サービス発売',
    'conference'     => 'カンファレンス・展示会',
    'webinar'        => 'ウェビナー・セミナー',
    'deadline'       => '締め切り・提出期限',
    'review'         => '振り返り・レビュー',
    'other'          => 'その他'
  }.freeze

  STATUSES = {
    'upcoming'    => '予定',
    'in_progress' => '進行中',
    'completed'   => '完了',
    'cancelled'   => 'キャンセル'
  }.freeze

  # イベント種別ごとの標準タスクテンプレート (日数は event_date からの相対日数)
  TASK_TEMPLATES = {
    'campaign' => [
      { title: 'ターゲットオーディエンスの定義・セグメント設計', days_before: 60, priority: 1 },
      { title: 'キャンペーンKPI・目標設定', days_before: 55, priority: 1 },
      { title: 'クリエイティブ制作（バナー・コピー）', days_before: 45, priority: 1 },
      { title: 'メディアプランニング・予算配分', days_before: 30, priority: 2 },
      { title: 'LP（ランディングページ）作成・確認', days_before: 21, priority: 1 },
      { title: 'コンテンツ最終承認・校正', days_before: 14, priority: 1 },
      { title: '配信テスト・動作確認', days_before: 7, priority: 1 },
      { title: '最終チェックリスト確認', days_before: 3, priority: 1 },
      { title: 'キャンペーン効果測定レポート作成', days_before: -7, priority: 2 },
      { title: '振り返りミーティング・改善点まとめ', days_before: -14, priority: 3 }
    ],
    'product_launch' => [
      { title: 'プレスリリース原稿作成', days_before: 45, priority: 1 },
      { title: 'メディアリスト・プレスキット作成', days_before: 30, priority: 1 },
      { title: 'SNSコンテンツ・投稿スケジュール準備', days_before: 21, priority: 2 },
      { title: '社内・ステークホルダーへの事前案内', days_before: 14, priority: 2 },
      { title: 'プレスリリース配信・メディアアウトリーチ', days_before: 7, priority: 1 },
      { title: 'ローンチ当日タイムライン確認・リハーサル', days_before: 3, priority: 1 },
      { title: 'SNS一斉投稿・告知', days_before: 0, priority: 1 },
      { title: 'メディア掲載・反応モニタリング', days_before: -3, priority: 2 },
      { title: 'ローンチ後フォローアップ・問い合わせ対応', days_before: -7, priority: 2 }
    ],
    'conference' => [
      { title: '出展・登壇申込み・手続き完了確認', days_before: 60, priority: 1 },
      { title: '展示ブース・資料デザイン発注', days_before: 45, priority: 1 },
      { title: '配布物（チラシ・名刺・ノベルティ）準備', days_before: 30, priority: 2 },
      { title: '展示物・デモ機材の動作確認', days_before: 14, priority: 1 },
      { title: '担当スタッフ・役割分担確認', days_before: 7, priority: 2 },
      { title: '会場設営・搬入確認', days_before: 1, priority: 1 },
      { title: '獲得リード・名刺のデータ化', days_before: -3, priority: 1 },
      { title: '展示会フォローアップメール送信', days_before: -7, priority: 1 }
    ],
    'webinar' => [
      { title: 'テーマ・アジェンダ・スピーカー確定', days_before: 30, priority: 1 },
      { title: '告知ページ・申込フォーム公開', days_before: 21, priority: 1 },
      { title: 'SNS・メールで集客告知開始', days_before: 14, priority: 2 },
      { title: 'リマインドメール配信（1週間前）', days_before: 7, priority: 2 },
      { title: '登壇資料・デモ環境最終確認', days_before: 3, priority: 1 },
      { title: 'リマインドメール配信（前日）', days_before: 1, priority: 2 },
      { title: '配信テスト・音声・映像確認', days_before: 0, priority: 1 },
      { title: 'アーカイブ動画公開・参加者フォローメール', days_before: -3, priority: 2 },
      { title: 'アンケート集計・効果測定', days_before: -7, priority: 3 }
    ],
    'deadline' => [
      { title: '必要書類・データの洗い出し', days_before: 30, priority: 1 },
      { title: '担当者・レビュアーのアサイン', days_before: 21, priority: 1 },
      { title: '初稿作成・内部レビュー依頼', days_before: 14, priority: 1 },
      { title: 'フィードバック反映・修正', days_before: 7, priority: 1 },
      { title: '最終確認・承認取得', days_before: 3, priority: 1 },
      { title: '提出・送付完了確認', days_before: 0, priority: 1 }
    ],
    'review' => [
      { title: 'KPI実績データ収集・整理', days_before: 14, priority: 1 },
      { title: '前回アクションアイテムの進捗確認', days_before: 7, priority: 2 },
      { title: 'レビュー資料・レポート作成', days_before: 3, priority: 1 },
      { title: 'ミーティング参加者への資料事前共有', days_before: 1, priority: 2 },
      { title: '次期アクションアイテム・改善策のまとめ', days_before: -3, priority: 1 }
    ],
    'other' => [
      { title: '事前準備・必要事項の確認', days_before: 14, priority: 2 },
      { title: '関係者への案内・調整', days_before: 7, priority: 2 },
      { title: '最終確認', days_before: 1, priority: 1 }
    ]
  }.freeze

  validates :title, presence: true
  validates :event_date, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES.keys }
  validates :status, presence: true, inclusion: { in: STATUSES.keys }

  scope :upcoming, -> { where('event_date >= ?', Date.today).order(:event_date) }
  scope :past, -> { where('event_date < ?', Date.today).order(event_date: :desc) }
  scope :this_month, -> { where(event_date: Date.today.beginning_of_month..Date.today.end_of_month) }
  scope :this_year, -> { where(event_date: Date.today.beginning_of_year..Date.today.end_of_year) }

  def category_label
    CATEGORIES[category] || category
  end

  def status_label
    STATUSES[status] || status
  end

  def days_until
    (event_date - Date.today).to_i
  end

  def urgency_level
    d = days_until
    if d < 0
      :past
    elsif d <= 3
      :critical
    elsif d <= 14
      :urgent
    elsif d <= 30
      :soon
    else
      :normal
    end
  end

  # イベント作成時にタスクを自動生成
  def generate_tasks!(user)
    templates = TASK_TEMPLATES[category] || TASK_TEMPLATES['other']
    templates.each do |tmpl|
      due = event_date + tmpl[:days_before].days
      tasks.create!(
        title: tmpl[:title],
        due_date: due,
        priority: tmpl[:priority],
        status: due < Date.today ? 'overdue' : 'pending',
        auto_generated: true,
        user: user
      )
    end
  end
end
