class InvitationsController < ApplicationController
  skip_filter :authenticate_user!, only: :accept
  before_action :authorize_invitation, except: :accept
  before_action :find_active_invitation, only: :accept
  before_action :find_invitation, only: [:destroy, :resend]

  def new
    @invitation = Invitation.new
  end

  def index
    @invitations = current_organization.invitations
  end

  def create
    @invitation = current_member.invitations.build(invitation_params)

    if @invitation.save
      redirect_to new_invitation_path, notice: 'An invitation was created successfully'
    else
      render :new
    end
  end

  def resend
    if @invitation.send_invitation
      redirect_to invitations_path, notice: 'An invitation has been resent'
    else
      redirect_to invitations_path, error: 'Couldn\'t resend an invitation'
    end
  end

  def destroy
    if @invitation.destroy
      redirect_to invitations_path, notice: 'An inventation was destroyed successfully'
    else
      redirect_to invitations_path, error: 'Couldn\'t destroy an invitation'
    end
  end

  def accept
    if @user = User.find_by(email: @invitation.email)
      if current_user == @user
        @invitation.accept!(@user)
        redirect_to root_path, notice: "You joined #{@invitation.member.organization.name}."
      else
        session['user_return_to'] = accept_invitation_path(token: @invitation.token)
        redirect_to new_user_session_path
      end
    else
      @user = User.new
    end
  end

  private

  def authorize_invitation
    authorize :invitation, :owner_or_admin_for_record?
  end

  def find_active_invitation
    @invitation = Invitation.active.find_by(token: params[:token])
    redirect_to root_path, alert: 'Bad invitation token' unless @invitation
  end

  def find_invitation
    @invitation = Invitation.find(params[:id])
  end

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end

  def user_params
    params.require(:user).permit(:full_name, :password)
  end
end
