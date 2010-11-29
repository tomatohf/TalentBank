ActionController::Routing::Routes.draw do |map|
  
  map.connect "/schools/:id/teachers/:page", :controller => "schools", :action => "teachers", :id => /\d+/, :page => /\d+/
  map.resources :schools, :collection => {
    
  }, :member => {
    :teachers => :get,
    
    :new_teacher => :get,
    :create_teacher => :post,
    
    :adjust_teacher_permission => :post
  }
  
  
  map.resources :teachers, :collection => {
    
  }, :member => {
    :edit_password => :get,
    :update_password => :post,
    
    :revisions => :get
  } do |teachers|
    teachers.resources :teacher_students, :as => :students, :member => {
      :resume => :get,
      
      :edit_profile => :get,
      :update_profile => :post,
      
      :edit_intern_profile => :get,
      :update_intern_profile => :post,
      
      :edit_intern_wishes => :get,
      :add_intern_wish => :post,
      :remove_intern_wish => :post
    } do |teacher_students|
      teacher_students.resources :teacher_student_intern_logs, :as => :intern_logs, :collection => {
        :set_calling_mark => :post,
        :clear_calling_mark => :post,
        
        :refresh_matched_student_status => :post
      }
    end
    
    teachers.resources :teacher_statistics, :as => :statistics, :collection => {
      :querying => :any,
      :viewing => :any,
      
      :details => :any,
      
      :university => :any,
      :college => :any,
      :major => :any,
      :student => :any,
      :viewing_domain => :any,
      :viewing_corp => :any,
      
      :querying_corp => :any,
      :querying_domain => :any,
      :tag => :any,
      :skill => :any,
      :skill_value => :any,
      :keyword => :any,
      
      
      :intern_logs => :any,
      :intern => :any
    }
    
    teachers.resources :teacher_corporations, :as => :corporations, :collection => {
      :autocomplete => :get
    }, :member => {
      :adjust_permission => :post
    } do |teacher_corporations|
      teacher_corporations.resources :teacher_corporation_records, :as => :records
      
      teacher_corporations.resources :teacher_corporation_jobs, :as => :jobs, :member => {
        :search => :get,
        :match => :get,
        
        :intern_logs => :get
      }
    end
  end
  
  
  map.connect "/students/:id/corporations/:corporation_id", :controller => "students", :action => "show_corporation", :id => /\d+/, :corporation_id => /\d+/
  map.resources :students, :collection => {
    
  }, :member => {
    :edit_job_photo => :get,
    :update_job_photo => :post,
    :destroy_job_photo => :post,
    
    :edit_profile => :get,
    :update_profile => :post,
    
    :edit_skills => :get,
    :update_skills => :post,
    
    :add_skill => :post,
    :remove_skill => :post,
    
    :blocked_corps => :get,
    :new_blocked_corp => :get,
    :create_blocked_corp => :post,
    :destroy_blocked_corp => :post
  } do |students|
    students.resources :edu_exps
    students.resources :student_exps, :as => :exps
    
    students.resources :resumes, :member => {
      :edit_job_intention => :get,
      :update_job_intention => :post,
      
      :include_skill => :post,
      :exclude_skill => :post,
      
      :edit_hobbies => :get,
      :update_hobbies => :post,
      
      :edit_awards => :get,
      :update_awards => :post,
      
      :add_exp_tag => :post,
      :remove_exp_tag => :post,
      
      :copy => :post,
      
      :restore => :post
    } do |resumes|
      resumes.resources :resume_list_sections, :as => :list_sections
      
      resumes.resources :resume_exp_sections, :as => :exp_sections, :member => {
        :new_resume_student_exp => :get,
        :create_resume_student_exp => :post,
        
        :destroy_resume_student_exp => :post,
        
        :update_exp_order => :post
      } do |resume_exp_sections|
        resume_exp_sections.resources :resume_exps, :as => :exps
      end
      
      resumes.resources :resume_skills
    end
  end
  
  
  map.resources :corporations, :collection => {
    
  }, :member => {
    :edit_password => :get,
    :update_password => :post,
    
    :edit_profile => :get,
    :update_profile => :post
  } do |corporations|
    corporations.resources :corp_saved_queries, :as => :saved_queries
    
    corporations.resources :corp_resumes, :as => :resumes, :collection => {
      :add_skill => :post,
      :create_query => :post
    }
    
    corporations.resources :corp_saved_resumes, :as => :saved_resumes, :collection => {
      :update_tag => :post,
      :destroy_tag => :post
    }
  end
  
  
  map.resources :revise_resumes, :path_prefix => "/:account_type/:account_id", :requirements => {
    :account_type => /(students|teachers)/,
    :account_id => /\d+/
  }, :only => [:show] do |revise_resumes|
    revise_resumes.resources :resume_revisions, :only => [:create, :update, :destroy], :as => :revisions, :member => {
      :update_applied => :post,
      :diff => :any,
      :apply => :post
    }, :collection => {
      :set_applied => :post
    }
    
    revise_resumes.resources :resume_comments, :only => [:create, :update, :destroy], :as => :comments
  end
  
  
  map.resource :notifications, :path_prefix => "/:account_type/:account_id", :requirements => {
    :account_type => /(students|teachers|corporations)/,
    :account_id => /\d+/
  }, :only => [:show] do |notifications|
    notifications.resources :notices, :only => [:index]
    
    notifications.resources :requests, :only => [:index, :create, :destroy], :member => {
      :accept => :post
    }, :collection => {
      :sent => :get
    }
  end
  
  
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => "index"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
