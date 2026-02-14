# CLAUDE.md

## Project Overview

This is a real-time chat application built with **Ruby on Rails 6.0** and **Ruby 2.6.5**. Users can register, create chat rooms, invite other users, and exchange text messages with image attachments. The UI is in Japanese.

## Tech Stack

- **Backend:** Rails 6.0.0, Ruby 2.6.5
- **Database:** MySQL (mysql2 gem)
- **Authentication:** Devise
- **Frontend:** Server-rendered ERB templates, Turbolinks, Webpacker 4.3
- **Real-time:** Action Cable (async in dev, Redis in production)
- **File uploads:** Active Storage with ImageMagick (mini_magick, image_processing)
- **CSS:** Plain CSS files via Rails asset pipeline (YUI 3.18.1 reset)
- **Testing:** RSpec, FactoryBot, Faker, Capybara, Selenium WebDriver

## Directory Structure

```
app/
  controllers/     # ApplicationController (global auth), RoomsController, MessagesController, UsersController
  models/          # User, Room, RoomUser (join table), Message
  views/           # ERB templates: devise/, messages/, rooms/, users/, layouts/
  channels/        # Action Cable (base connection/channel only)
  assets/          # CSS files: application.css, messages.css, room.css, user.css
  javascript/      # Webpacker entry point (packs/application.js), Action Cable consumer
config/
  routes.rb        # Devise routes, rooms (nested messages), users
  database.yml     # MySQL config (dev/test/prod)
  cable.yml        # Action Cable adapters per environment
  webpacker.yml    # Webpack configuration
  initializers/    # devise.rb is the key initializer
db/migrate/        # 5 migrations: users, rooms, room_users, messages, active_storage
spec/
  models/          # Unit tests for User, Room, Message
  system/          # Integration tests for messages, rooms, users (Capybara)
  factories/       # FactoryBot factories for all models
  support/         # sign_in_support.rb helper
```

## Data Model

- **User** - has_many :rooms (through :room_users), has_many :messages. Devise auth with name field.
- **Room** - has_many :users (through :room_users), has_many :messages. Dependent destroy on associations.
- **RoomUser** - Join table linking users to rooms.
- **Message** - belongs_to :room, belongs_to :user. Has optional image attachment (Active Storage). Content required unless image is attached.

## Routes

```
devise_for :users                              # Auth routes (sign up, sign in, etc.)
root to: "rooms#index"                         # Landing page
resources :users, only: [:edit, :update]       # Profile editing
resources :rooms, only: [:new, :create, :destroy] do
  resources :messages, only: [:index, :create] # Nested messages
end
```

## Development Commands

```bash
# Setup
bundle install
yarn install
rails db:create db:migrate

# Run server
rails server                    # Starts Puma on localhost:3000
./bin/webpack-dev-server        # Separate terminal for Webpack hot reload

# Testing
bundle exec rspec               # Run all specs
bundle exec rspec spec/models/  # Run model specs only
bundle exec rspec spec/system/  # Run system/integration specs only

# Database
rails db:migrate                # Run pending migrations
rails db:rollback               # Rollback last migration
rails db:seed                   # Seed data (if seeds.rb is populated)

# Console
rails console                   # Interactive Rails console
```

## Testing Conventions

- **Framework:** RSpec with `--format documentation`
- **Factories:** Use FactoryBot (`build`, `create`) instead of fixtures. Defined in `spec/factories/`.
- **System tests:** Use Capybara with Selenium. Sign-in helper at `spec/support/sign_in_support.rb`.
- **Test locale:** English (`I18n.locale = "en"` in rails_helper.rb), even though the app UI is Japanese.
- **Transactional fixtures:** Enabled - database rolls back after each test.
- **Test image:** Located at `public/images/test_image.png` for attachment tests.

## Key Conventions

- **Authentication:** All controllers require authentication via `before_action :authenticate_user!` in ApplicationController. Devise handles sign-up/sign-in/password reset.
- **Strong parameters:** Each controller defines its own `_params` private method for permitted attributes.
- **Eager loading:** Messages are loaded with `includes(:user)` to avoid N+1 queries.
- **Locale:** App default is Japanese (`:ja`), timezone is Tokyo.
- **No generators for:** stylesheets, javascripts, helpers, or test framework (disabled in `config/application.rb`).
- **Commit messages:** Written in Japanese, following feature-branch PR workflow.

## Environment Variables

| Variable | Environment | Purpose |
|---|---|---|
| `CHAT_APP_DATABASE_PASSWORD` | Production | MySQL password |
| `REDIS_URL` | Production | Redis for Action Cable (default: `redis://localhost:6379/1`) |
| `RAILS_MAX_THREADS` | All | Database connection pool size (default: 5) |

## Architecture Notes

- This is a traditional Rails monolith with server-rendered views (no SPA framework).
- Action Cable infrastructure exists but is not actively used for real-time messaging; messages are submitted via standard HTTP POST and the page reloads.
- Image uploads use Active Storage with local disk storage in development. Production can be configured for cloud storage in `config/storage.yml`.
- CSS uses plain stylesheets (no Tailwind/Bootstrap). Layout is flexbox-based with a sidebar + chat panel pattern.
