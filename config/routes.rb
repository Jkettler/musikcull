Rails.application.routes.draw do
  concern :paginatable do
    get '(page/:page)', action: :page, on: :collection, as: ''
  end

  resources :artists, concerns: :paginatable do
    collection do
      get 'search'
      get 'page'
    end
  end

  resources :albums, concerns: :paginatable do
    collection do
      get 'search'
      get 'page'
      get 'title_frequency'
    end
  end
end
