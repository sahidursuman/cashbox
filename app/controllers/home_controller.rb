class HomeController < ApplicationController
  before_filter :require_organization

  def show
    @q = current_organization.transactions.ransack(params[:q])
    @transactions = @q.result.order(created_at: :desc)
    for_flow = @transactions.without_hidden
    @rub_flow = Money.new(for_flow.by_currency("RUB").sum(:amount_cents), 'rub')
    @usd_flow = Money.new(for_flow.by_currency("USD").sum(:amount_cents), 'usd')
    @transactions = @transactions.page(params[:page]).per(10)
    @bank_accounts = current_organization.bank_accounts
  end
end
