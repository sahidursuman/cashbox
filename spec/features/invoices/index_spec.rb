require 'spec_helper'

describe 'invoices index page' do
  let(:user) { create :user }
  let(:org)  { create :organization, with_user: user }

  before do
    sign_in user
  end

  include_context 'invoices pagination'
  it_behaves_like 'paginateable' do
    let!(:list)      { create_list :invoice, invoices_count, organization: org }
    let(:list_class) { '.invoices' }
    let(:list_page)  { invoices_path }
  end

  context "show only current organization's invoices" do
    let(:org1) { create :organization, with_user: user }
    let(:org2) { create :organization, with_user: user }
    let!(:org1_invoice) { create :invoice, organization: org1 }
    let!(:org2_invoice) { create :invoice, organization: org2 }

    before do
      visit invoices_path
    end

    it "invoice index page displays current organization's invoices" do
      expect(page).to have_content(org1_invoice.customer)
    end

    it "invoice index page doesn't display another invoices" do
      expect(page).to_not have_content(org2_invoice.customer)
    end
  end

  context 'colorize invoice' do
    let!(:overdue_invoice) { create :invoice, organization: org, ends_at: Date.current - 16.days }
    let!(:paid_invoice) { create :invoice, organization: org, paid_at: Date.current }

    before do
      visit invoices_path
    end

    it "overdue invoice has class 'overdue'" do
      within '#invoices_list' do
        expect(page).to have_css("tr.invoice.overdue##{dom_id(overdue_invoice)}")
      end
    end

    it "paid invoice has class 'paid'" do
      within '#invoices_list' do
        expect(page).to have_css("tr.invoice.paid##{dom_id(paid_invoice)}")
      end
    end
  end

  context 'complete invoice', js: true do
    let!(:account)  { create :bank_account, organization: org }
    let!(:category) { create :category, :income, organization: org }
    let!(:wrong_category) { create :category, :expense, organization: org }
    let!(:wrong_account)  { create :bank_account, organization: org, currency: 'USD' }
    let!(:invoice)  { create :invoice, organization: org, amount: 500 }
    let(:comission) { Money.new(100, invoice.currency) }

    def create_transaction_by_invoice
      visit invoices_path
      click_on 'Complete Invoice'
      within '#new_transaction' do
        select category.name, from: 'transaction[category_id]'
        select account.name, from: 'transaction[bank_account_id]'
        fill_in 'transaction[comission]', with: comission
        fill_in 'transaction[comment]', with: 'TestComment'
      end
      expect(page).to_not have_select('Category', with_options: [wrong_category.name])
      expect(page).to_not have_select('Bank Account', with_options: [wrong_account.name])
      expect(page).to have_field('Comission', with: comission)
      expect(page).to have_content("Total amount: #{invoice.amount - comission}" )
      click_on 'Create'
      sleep 1 # wait after page rerender
    end

    subject{ create_transaction_by_invoice; page }

    context 'update invoice paid_at after create transaction' do
      before do
        create_transaction_by_invoice
        visit invoices_path
      end

      it 'invoice paid_at must present' do
        expect(page).to have_content(invoice.paid_at)
      end
    end

    context 'with valid data' do
      it 'creates a new transaction' do
        expect{ subject }.to change(Transaction, :count).by(1)
      end

      context 'check transaction' do
        before do
          create_transaction_by_invoice
          visit root_path
        end

        it 'shows created transaction in transactions list' do
          expect(page).to have_content(money_with_symbol(invoice.amount - comission))
          expect(page).to have_content(category.name)
          expect(page).to have_content(account.name)
          expect(page).to have_content('TestComment')
          expect(page).to have_content(I18n.l(Date.current))
        end
      end
    end
  end
end
