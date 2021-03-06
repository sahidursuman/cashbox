class ApplicationPolicy
  attr_reader :member, :record

  def initialize(member, record)
    @member = member
    @record = record
    @invited_by = member
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(member, record.class)
  end

  class Scope
    attr_reader :member, :scope

    def initialize(member, scope)
      @member = member
      @scope = scope
    end

    def resolve
      scope
    end
  end

  protected
    def owner_or_admin_with_access?
      (member.admin? && record.role != 'owner') || member.owner?
    end
end
