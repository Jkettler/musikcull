Rails.application.routes.draw do
  concern :paginatable do
    get '(page/:page)', action: :page, on: :collection, as: ''
  end

  resources :artists do
    collection do
      get 'search'
    end
  end

  resources :albums, concerns: :paginatable do
    collection do
      get 'search'
      get 'page'
    end
  end
end
