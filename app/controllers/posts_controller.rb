require "net/http"
require "rexml/document"
class PostsController < ApplicationController
  before_filter :get_user
  
  def get_user
    unless cookies[:hash] == nil
      @user = User.find_hashed(cookies[:hash])
    end
  end
    
  def index
    list
    render :action => 'list'
  end

  def signup
    # @user = User.new(params[:user])
    # if @user.save
    #   private_login
    #   flash[:notice] = "Signup successful."
    #   redirect_to :action => "list"
    # else
    #   flash[:notice] = "Something went wrong with your signup, please try again."
    # end
  end
  
  def login
    if request.post?
      if private_login
        flash[:notice] = "Login successful"
      else
        flash[:notice] = "Login unsuccessful"
      end
      redirect_to :action => "list"
    end
  end
  
  def private_login
    user = User.authenticate(params[:user][:name], params[:user][:password])
    if user
      cookies[:hash] = {
        :value => user.id.to_s + "--" + user.password, :expires => Time.now + 1.year
      }
      return true
    else
      return false
    end
  end
  
  
  def logout
    cookies.delete :hash
    redirect_to :back
  end
  
  def list_backup
    @post = Post.new
    @post_pages, @posts = paginate :posts, :per_page => 10, :order => "created_on DESC"
  end
  
  def newFile
    @file = File.new
  end
  
  def rss
    @posts = Post.find(:all, :order => 'created_on DESC', :limit => 50)
    render_without_layout
  end
  
  def admin_majick
    cookies[:admin] = "true"
    redirect_to :action => "list"
  end
  
  def list
    @cookie = cookies[:admin]
    @files = latestFive
    @post = Post.new
    @posts = Post.paginate :page => params[:page], :order => 'created_on DESC'
    # @post_pages = Paginator.new self, Post.count, 10, @params['page']
    # @posts = Post.find(:all, :order => 'created_on DESC', :limit => @post_pages.items_per_page, :offset => @post_pages.current.offset) 
  end
  
  def allFiles
    @files =  PartyFile.find(:all)
  end
  
  def search
    @files = latestFive
    @post = Post.new
    flash[:notice] = "Search results for #{params[:searchString]}"
    @posts = Post.find_by_sql ["SELECT * FROM posts WHERE MATCH (body) AGAINST(?)", params[:searchString]]
    @post_pages = Paginator.new self, @posts.length, 10, params['page']
    @posts = Post.find(:all, :order => 'created_on DESC', :limit => @post_pages.items_per_page, :offset => @post_pages.current.offset, :conditions => ["MATCH (body) AGAINST(?)", params[:searchString]]) 
    render :action => 'list'
  end
  
  def show
    @post = Post.find(params[:id])
  end

  def create
    @post = Post.new
    @post.body = params[:post][:body]
    if @post.save
      @user.posts << @post
      session[:post_edit] = @post.id
      flash[:notice] = 'Post was successfully created.'
      redirect_to :action => 'list'
    else
      redirect_to :action => 'list'
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.user.id == @user.id or cookies[:admin]
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        redirect_to :action => 'list'
      else
        render :action => 'edit'
      end
    else
      flash[:notice] = "you don't own that post"
      redirect_to :action => "list"
    end
  end

  def destroy
    if cookies[:admin]
      Post.find(params[:id]).destroy
      redirect_to :action => 'list'
    end
  end
  
  def newFile
    @file = PartyFile.new
    if @request.post?
      @file.position = params[:position]
      @file.save
      if params[:type] == "thread" 
        @file.title = params[:title]
        post = Post.new
        post.body = params[:post]
        post.author = params[:name]
        @file.posts << post
      else
        @file.filename = sanitize_filename(params[:file].original_filename)
        real_filename = @file.id.to_s + "." + @file.filename.split('.').last
        File.open("#{RAILS_ROOT}/public/files/#{real_filename}", "w") do |f|
          f.write(params[:file].read)
        end
      end
      @file.update
      flash[:notice] = 'file successfully uploaded.'
      redirect_to :action => 'list'
    end
  end
  
  def ajax_call
    render :partial => "ajax_jamz"
  end
  
  private
  
  def sanitize_filename(original_filename)
    just_filename = original_filename.gsub(/^.*(\\|\/)/, '')
    just_filename.gsub(/[^\w\.\-]/,'_') 
  end
  
  def latestFive
    theFive = []
    counter = 0
    5.times do
      file = PartyFile.find(:first, :conditions => "position = #{counter}", :order => 'created_on DESC')
      theFive << file
      counter += 1
    end
    return theFive
  end
  
end
