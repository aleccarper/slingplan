Rails.application.routes.draw do

  mount StripeEvent::Engine => '/stripe-hooks'
  mount_griddler

  # ---------------------------------------------------------------
  # Environment-Agnostic
  # ---------------------------------------------------------------
  root to: 'home#index'
  get 'map', to: 'map#index'
  get 'legal/terms', to: 'legal#terms_of_service'
  get 'legal/privacy', to: 'legal#privacy_policy'
  post 'validate', to: 'validation#validate'
  post 'validate_all', to: 'validation#validate_all'
  get 'tooltips', to: 'tooltips#for_route'
  get 'email_processor', to: proc { [200, {}, ['OK']] }, as: 'mandrill_head_test_request'

  # ---------------------------------------------------------------
  # Things Exploding
  # ---------------------------------------------------------------
  match '404', to: 'errors#file_not_found', via: :all
  match '500', to: 'errors#internal_server_error', via: :all
  match '422', to: 'errors#unprocessable', via: :all

  # ---------------------------------------------------------------
  # Seo And Friends
  # ---------------------------------------------------------------
  if not Rails.env.production?
    get 'robots.txt' => 'home#robots'
  end

  # ---------------------------------------------------------------
  # Pre-launch Subscription
  # ---------------------------------------------------------------
  if ENV['HOLDING'] == 'true'
    post 'launch_subscriber/create', to: 'launch_subscribers#create'
    get 'launch_subscriber/success', to: 'launch_subscriber#success'
  end

  # ---------------------------------------------------------------
  # Maintenance
  # ---------------------------------------------------------------
  if ENV['MAINTENANCE'] == 'true'
    get '*path' => redirect('/')
  end

  # ---------------------------------------------------------------
  # Beta
  # ---------------------------------------------------------------
  if ENV['BETA'] == 'true'
    post 'beta', to: 'beta#login'
  end

  # ---------------------------------------------------------------
  # Production
  # ---------------------------------------------------------------
  if ENV['MAINTENANCE'] == 'false'

    # /blog
    resources :blog, only: [:index, :show]

    # /coupon
    post 'validate_coupon', to: 'coupon#validate_coupon'

    # /map
    post 'map/render_view_state', to: 'map#render_view_state'
    post 'map/service_results', to: 'map#service_results'

    # /bookmarks
    delete 'bookmark/:bookmark_list_id/:id', to: 'bookmarks#remove_from_bookmark_list'
    delete 'bookmark/:id', to: 'bookmarks#remove'
    delete 'bookmark_list/:bookmark_list_id', to: 'bookmarks#delete_bookmarks_list'
    get 'bookmarks/print_friendly', to: 'bookmarks#print_friendly'
    get 'bookmarks/to_file', to: 'bookmarks#to_file'
    post 'create_bookmark_list', to: 'bookmarks#create_bookmark_list'
    post 'email_bookmarks', to: 'bookmarks#email'
    put 'bookmark/:bookmark_list_id/:id', to: 'bookmarks#add_to_bookmark_list'
    put 'bookmark/:id', to: 'bookmarks#add'

    # /locations
    resources :locations, only: [:show], constraints: { id: /\d*/ }
    resources :locations, except: [:show]
    get 'locations/filter', to: 'locations#filter'
    get 'locations/available_services', to: 'locations#available_services'
    get 'locations/states_with_locations', to: 'locations#states_with_locations'

    # /vendors
    resources :vendors, except: [:show]
    get 'vendors/:id', to: 'vendors#show', constraints: { id: /\d+/ }
    get 'vendors/:id/:name', to: 'vendors#show', constraints: { id: /\d+/ }
    post 'vendors/:id/page_state', to: 'vendors#page_state'

    # /staffers
    get 'staffers/:id/resume', to: 'staffers#resume'

    # /inquiries
    post 'inquiries/create_inquiry_message', to: 'inquiries#create_inquiry_message'
    post 'inquiries/read_inquiry_messages', to: 'inquiries#read_inquiry_messages'
    post 'inquiries/create_negotiation_message', to: 'inquiries#create_negotiation_message'
    post 'inquiries/read_negotiation_messages', to: 'inquiries#read_negotiation_messages'
    post 'inquiries/create_negotiation_message_bid', to: 'inquiries#create_negotiation_message_bid'
    get 'negotiations/:id/download_attachment', to: 'inquiries#download_attachment'


    # /notifications
    resources :notifications, except: [:show, :index, :create, :destroy, :update]
    get 'notifications/stream' => 'notifications#stream'
    post 'notifications/read', to: 'notifications#read'



    # controllers/sign_in
    get 'signin', to: 'signin#index'



    # ---------------------------------------------------------------
    # Admin
    # ---------------------------------------------------------------
    devise_for :admin,
      path: 'admin',
      controllers: {
        sessions: 'admin/sessions'
      }
    namespace :admin do
      authenticate :admin do
        # default admin panel route
        get '/', to: redirect('/admin/locations')

        # /admin/locations
        resources :locations, except: [:show]
        get 'locations/claims', to: 'locations/claims#index'
        get 'locations/seed', to: 'locations#seed'
        post 'locations/seed', to: 'locations#seed_upload'
        post 'locations/update_status', to: 'locations#update_status'
        post 'locations/page_state', to: 'locations#page_state'

        # /admin/locations
        namespace :locations do
          resources :claims, only: [:index]
          get 'claims/:id/approve', to: 'claims#approve'
          get 'claims/:id/deny', to: 'claims#deny'
        end

        # /admin/blog
        resources :blog

        # /admin/stripe
        resources :stripe, except: [:show]
        get 'stripe/new_coupon', to: 'stripe#new_coupon'
        post 'stripe/create_coupon', to: 'stripe#create_coupon'
        post 'stripe/delete_coupon', to: 'stripe#delete_coupon'

        # /admin/inquiries
        resources :inquiries, except: [:show]
        resources :inquiries, only: [:show], constraints: { id: /\d*/ }
        get 'inquiries/:id/stream' => 'inquiries#stream'
        get 'inquiries/:id/stream_new_message_buttons' => 'inquiries#stream_new_message_buttons'
        post 'inquiries/create_message', to: 'inquiries#create_message'
        post 'inquiries/page_closed', to: 'inquiries#page_closed'
        post 'inquiries/page_open', to: 'inquiries#page_open'
        put 'inquiries/:id/reopen', to: 'inquiries#reopen'
        namespace :inquiries do
          # /admin/inquiries/suggestions
          resources :suggestions
          # /admin/inquiries/questions
          resources :questions
          # /admin/inquiries/suggestions
          resources :bug_reports
        end
      end
    end



    # ---------------------------------------------------------------
    # Staffer
    # ---------------------------------------------------------------
    devise_for :staffer,
      path: 'staffers/admin',
      controllers: {
        sessions: 'staffers/admin/sessions',
        registrations: 'staffers/admin/registrations',
        passwords: 'staffers/admin/passwords'
      }
    namespace :staffers do
      namespace :admin do
        authenticate :staffer do
          # default staffer admin panel route
          get '/', to: redirect('/staffers/admin/profile')

          # devise custom
          devise_scope :vendor do
            get 'sign_up/plan', to: 'registrations#plan'
            post 'sign_up/subscribe', to: 'registrations#subscribe'
          end

          # /staffers/admin/profile
          resources :profile, only: [:index, :edit, :update]

          # /staffers/admin/inquiries
          resources :inquiries, except: [:show]
          resources :inquiries, only: [:show], constraints: { id: /\d*/ }
          get 'inquiries/:id/stream' => 'inquiries#stream'
          get 'inquiries/:id/stream_negotiation' => 'inquiries#stream_negotiation'
          get 'inquiries/:id/stream_new_negotiation_message_buttons' => 'inquiries#stream_new_negotiation_message_buttons'
          get 'inquiries/:id/stream_vendor_rfp' => 'inquiries#stream_vendor_rfp'
          post 'inquiries/create_message', to: 'inquiries#create_message'
          post 'inquiries/create_service_request', to: 'inquiries#create_service_request'
          post 'inquiries/page_closed', to: 'inquiries#page_closed'
          post 'inquiries/page_open', to: 'inquiries#page_open'
          namespace :inquiries do
            # /staffers/admin/inquiries/suggestions
            resources :suggestions
            # /staffers/admin/inquiries/questions
            resources :questions
            # /staffers/admin/inquiries/bug_reports
            resources :bug_reports
            # /staffers/admin/inquiries/negotiations
            resources :negotiations
          end

          # /staffers/admin/account
          get 'account', to: 'account#index'
          namespace :account do
            # /staffers/admin/account/billing
            resources :billing, except: [:show, :destroy, :update]
            resources :billing, only: [:show], constraints: { id: /\d*/ }
            delete 'billing/cancel_subscription', to: 'billing#cancel_subscription'
            get 'billing/card', to: 'billing#card'
            get 'billing/coupon', to: 'billing#coupon'
            get 'billing/plan', to: 'billing#plan'
            patch 'billing/reactivate_subscription', to: 'billing#reactivate_subscription'
            post 'billing/activate_coupon', to: 'billing#activate_coupon'
            post 'billing/change_plan', to: 'billing#change_plan'
            post 'billing/create_subscription', to: 'billing#create_subscription'
            post 'billing/update_billing', to: 'billing#update_billing'
            post 'billing/activate_coupon', to: 'billing#activate_coupon'
            delete 'billing/cancel_subscription', to: 'billing#cancel_subscription'
            patch 'billing/reactivate_subscription', to: 'billing#reactivate_subscription'

            # /staffers/admin/account/settings
            get 'settings', to: 'settings#index'
            patch 'settings', to: 'settings#update'
          end
        end
      end
    end


    # ---------------------------------------------------------------
    # Vendor
    # ---------------------------------------------------------------
    devise_for :vendor,
      path: 'vendors/admin',
      controllers: {
        sessions: 'vendors/admin/sessions',
        registrations: 'vendors/admin/registrations',
        passwords: 'vendors/admin/passwords'
      }
    namespace :vendors do
      namespace :admin do
        authenticate :vendor do
          # default vendor admin panel route
          get '/', to: redirect('/vendors/admin/locations')

          # devise custom
          devise_scope :vendor do
            get 'sign_up/plan', to: 'registrations#plan'
            post 'sign_up/subscribe', to: 'registrations#subscribe'
          end

          # /vendors/admin/locations
          resources :locations, except: [:show]
          resources :locations, only: [:show], constraints: { id: /\d*/ }
          namespace :locations do
            resources :claims, only: [:index]
            get 'claims/:id/cancel', to: 'claims#cancel'
          end

          post 'locations/:id/events/page_future', to: 'locations/events#page_future'
          post 'locations/:id/events/page_past', to: 'locations/events#page_past'
          post 'locations/:id/events/page_today', to: 'locations/events#page_today'

          get 'locations/:id/clone', to: 'locations#clone'
          get 'locations/:id/edit/:page', to: 'locations#edit'
          get 'locations/:id/events/:event_id/manage', to: 'locations/events#manage'
          get 'locations/claimed', to: 'locations#claimed'
          get 'locations/complete/:id', to: 'locations#complete'
          get 'locations/complete/:id', to: 'locations#complete'
          post 'locations/claim', to: 'locations#claim'
          post 'locations/confirm', to: 'locations#confirm'
          post 'locations/page_negotiating', to: 'locations#page_negotiating'
          post 'locations/page_state', to: 'locations#page_state'
          post 'locations/page_unconfirmed', to: 'locations#page_unconfirmed'
          post 'locations/update_status', to: 'locations#update_status'

          # /vendors/admin/inquiries
          resources :inquiries, except: [:show]
          resources :inquiries, only: [:show], constraints: { id: /\d*/ }
          namespace :inquiries do
            # /vendors/admin/inquiries/suggestions
            resources :suggestions
            # /vendors/admin/inquiries/questions
            resources :questions
            # /vendors/admin/inquiries/bug_reports
            resources :bug_reports
            # /vendors/admin/inquiries/negotiations
            resources :negotiations
          end
          get 'inquiries/:id/stream' => 'inquiries#stream'
          get 'inquiries/:id/stream_negotiation' => 'inquiries#stream_negotiation'
          get 'inquiries/:id/stream_vendor_rfp' => 'inquiries#stream_vendor_rfp'
          post 'inquiries/page_closed', to: 'inquiries#page_closed'
          post 'inquiries/page_open', to: 'inquiries#page_open'

          # /vendors/admin/account
          get 'account', to: 'account#index'
          namespace :account do
            # /vendors/admin/account/profile
            resources :profile, only: [:index, :edit, :update]

            # /vendors/admin/account/billing
            resources :billing, except: [:show, :destroy, :update]
            resources :billing, only: [:show], constraints: { id: /\d*/ }
            delete 'billing/cancel_subscription', to: 'billing#cancel_subscription'
            get 'billing/card', to: 'billing#card'
            get 'billing/coupon', to: 'billing#coupon'
            get 'billing/plan', to: 'billing#plan'
            patch 'billing/reactivate_subscription', to: 'billing#reactivate_subscription'
            post 'billing/activate_coupon', to: 'billing#activate_coupon'
            post 'billing/change_plan', to: 'billing#change_plan'
            post 'billing/create_subscription', to: 'billing#create_subscription'
            post 'billing/update_billing', to: 'billing#update_billing'
            post 'billing/activate_coupon', to: 'billing#activate_coupon'
            delete 'billing/cancel_subscription', to: 'billing#cancel_subscription'
            patch 'billing/reactivate_subscription', to: 'billing#reactivate_subscription'
            patch 'billing/cancel_trial', to: 'billing#cancel_trial'

            # /vendors/admin/account/settings
            get 'settings', to: 'settings#index'
            patch 'settings', to: 'settings#update'
          end
        end
      end
    end



    # ---------------------------------------------------------------
    # Planner
    # ---------------------------------------------------------------
    devise_for :planner,
      path: 'planners/admin',
      controllers: {
        sessions: 'planners/admin/sessions',
        registrations: 'planners/admin/registrations',
        passwords: 'planners/admin/passwords'
      }
    namespace :planners do
      namespace :admin do
        authenticate :planner do
          # default planner admin panel route
          get '/', to: redirect('/planners/admin/events')

          # devise custom
          devise_scope :planner do
            get 'sign_up/plan', to: 'registrations#plan'
            post 'sign_up/subscribe', to: 'registrations#subscribe'
          end

          # /planners/admin/events
          resources :events, except: [:show]
          get 'events/:id/service_rfp', to: 'events#show_service_rfp'
          get 'events/:id/service_rfp/:service_rfp_id', to: 'events#show_service_rfp'
          get 'events/:id/clone', to: 'events#clone'
          get 'events/:id/edit/service_rfp', to: 'events#edit_service_rfp'
          get 'events/:id/edit/service_rfp/:service_rfp_id', to: 'events#edit_service_rfp'
          get 'events/:id/print_friendly', to: 'events#print_friendly_event'
          get 'events/:id/service_rfps/:service_rfp_id/print_friendly', to: 'events#print_friendly_service_rfp'
          get 'events/complete/:id', to: 'events#complete'
          get 'events/:id/edit/:page', to: 'events#edit'
          patch 'events/:id/edit/service_rfp/:service_rfp_id', to: 'events#update_service_rfp'
          post 'events/:id/edit/service_rfp/:service_rfp_id/cancel_outside_arrangements', to: 'events#cancel_outside_arrangements'
          post 'events/:id/edit/service_rfp/:service_rfp_id/make_outside_arrangements', to: 'events#make_outside_arrangements'
          post 'events/:id/page_service_rfp', to: 'events#page_service_rfp'
          post 'events/get_eligible_services', to: 'events#get_eligible_services'
          post 'events/hide_location_from_service_rfp', to: 'events#hide_location_from_service_rfp'
          post 'events/page_future', to: 'events#page_future'
          post 'events/page_past', to: 'events#page_past'
          post 'events/page_today', to: 'events#page_today'
          post 'events/page_unconfirmed', to: 'events#page_unconfirmed'
          post 'events/page_service_rfp_locations', to: 'events#page_service_rfp_locations'
          post 'events/undo_hide_location_from_service_rfp', to: 'events#undo_hide_location_from_service_rfp'

          # /planners/admin/inquiries
          resources :inquiries, except: [:show]
          resources :inquiries, only: [:show], constraints: { id: /\d*/ }
          get 'inquiries/:id/stream' => 'inquiries#stream'
          get 'inquiries/:id/stream_negotiation' => 'inquiries#stream_negotiation'
          get 'inquiries/:id/stream_new_negotiation_message_buttons' => 'inquiries#stream_new_negotiation_message_buttons'
          get 'inquiries/:id/stream_vendor_rfp' => 'inquiries#stream_vendor_rfp'
          post 'inquiries/create_message', to: 'inquiries#create_message'
          post 'inquiries/create_service_request', to: 'inquiries#create_service_request'
          post 'inquiries/page_closed', to: 'inquiries#page_closed'
          post 'inquiries/page_open', to: 'inquiries#page_open'
          namespace :inquiries do
            # /planners/admin/inquiries/suggestions
            resources :suggestions
            # /planners/admin/inquiries/questions
            resources :questions
            # /planners/admin/inquiries/bug_reports
            resources :bug_reports
            # /planners/admin/inquiries/negotiations
            resources :negotiations
          end

          # /planners/admin/account
          get 'account', to: 'account#index'
          namespace :account do
            # /planners/admin/account/profile
            resources :profile, only: [:index, :edit, :update]

            # /planners/admin/account/billing
            #resources :billing, except: [:show, :destroy, :update]
            #resources :billing, only: [:show], constraints: { id: /\d*/ }
            #delete 'billing/cancel_subscription', to: 'billing#cancel_subscription'
            #get 'billing/card', to: 'billing#card'
            #get 'billing/coupon', to: 'billing#coupon'
            #get 'billing/plan', to: 'billing#plan'
            #patch 'billing/reactivate_subscription', to: 'billing#reactivate_subscription'
            #post 'billing/activate_coupon', to: 'billing#activate_coupon'
            #post 'billing/change_plan', to: 'billing#change_plan'
            #post 'billing/create_subscription', to: 'billing#create_subscription'
            #post 'billing/update_billing', to: 'billing#update_billing'

            # /planners/admin/account/settings
            get 'settings', to: 'settings#index'
            patch 'settings', to: 'settings#update'
          end
        end
      end
    end



    # ---------------------------------------------------------------
    # Url Based Filtering Of Vendor Locations
    #
    #   Expected Format:
    #     /:country_code/:state/:city/:vendor_name
    #
    #   Examples:
    #     /us
    #       => All in the United States
    #
    #     /us/co
    #       => All in Colorado
    #
    #     /us/co/denver
    #       => All in Denver, Colorado
    #
    #     /us/co/denver/acme-rentals
    #       => All in Denver, Colorado belonging to "Acme Rentals"
    # ---------------------------------------------------------------
    scope constraints: lambda { |req|
      path = req.env['REQUEST_PATH']
      # get path without leading '/' if present
      path.sub!(/^\//, '')
      # get first segment of url (THIS/not-this/or-this)
      if path.include? '/'
        # grab first segment if more than 1 segment exists
        first_segment = path[0..(path.index('/')-1)]
      else
        # grab unsegmented path
        first_segment = path
      end
      supported_countries = ['us']
      # ensure path doesn't start with an existing initial path segment
      supported_countries.include? first_segment
    } do
      get '/*filter', to: 'map#route_filter'
    end
  end
end
