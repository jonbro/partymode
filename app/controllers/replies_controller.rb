class RepliesController < ApplicationController
  before_filter :get_user
  
  def get_user
    unless cookies[:hash] == nil
      @user = User.find_hashed(cookies[:hash])
    end
  end

  def list
    @post = Post.find(params[:id])
  end
  
  def edit
    @reply = Reply.find(params[:id])
  end
  
  def update
    @reply = Reply.find(params[:id])
    if @reply.user.id == @user.id
      if @reply.update_attributes(params[:reply])
        flash[:notice] = 'Reply was successfully updated.'
        redirect_to :action => 'list', :id => @reply.post.id
      else
        render :action => 'edit'
      end
    else
      flash[:notice] = "you don't own that reply"
      redirect_to :action => "list", :id => @reply.post.id
    end
  end
  
  def create
    @post = Post.find(params[:id])
    @reply = Reply.new
    @reply.body = params[:reply][:body]
    @reply.title = ""
    if @reply.save
      @user.replies << @reply
      @post.replies << @reply
      flash[:notice] = 'Reply was successfully created.'
      redirect_to :action => 'list', :id => @post.id
    else
      redirect_to :action => 'list'
    end
  end
  
end