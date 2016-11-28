class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = Event.user_events(current_user, params[:start], params[:end])
  end

  def show
  end

  def new
    @event = Event.new
    @clients = Client.all
    @users = User.all
  end

  def edit
  end

  def create
    @event = Event.new(event_params)
    unless @event.new_name.blank? || @event.new_email.blank?
      new_client = Client.create(name: @event.new_name, email: @event.new_email)
      @event.clients << new_client
    end
    if @event.valid?
      @event.save
      begin
        @event.clients.each do |client|
          EventMailer.appointment_notification(@event, client).deliver_later(queue: "high")
        end
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError
        flash[:success] ="There was an error with the email server. No email was sent."
      end
    else
      flash[:success] ="I'm sorry, that is not a valid date. Please try again"
    end
  end

  def update
    @event.update(event_params)
    begin
      @event.clients.each do |client|
        EventMailer.appointment_notification(@event, client).deliver_later
      end
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError
      flash[:success] ="There was an error with the email server. Please try again."
    end
  end

  def destroy
    @event.destroy
    begin
      @event.clients.each do |client|
        EventMailer.appointment_cancel(@event, client).deliver_later(queue: "low")
      end
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError
      flash[:success] ="There was an error with the email server. Please try again."
    end
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:title, :date_range, :start, :end, :color, :notes, :room, :new_name, :new_email, :client_ids => [], :user_ids => [])
    end
end
