# frozen_string_literal: true

# statements fix Circular dependancy errors due to threading
# see: https://github.com/grosser/parallel#nameerror-uninitialized-constant
OrgDateRangeable.class
StatCreatedPlan.class
StatCreatedPlan::CreateOrUpdate.class
Role.class
User.class
Plan.class
Perm.class
Template.class

# Org usage --- TODO: This should likely be a module
class Org
  # Usage for Nbr of created plans in the prior month
  class CreateLastMonthCreatedPlanService
    class << self
      def call(org = nil, threads: 0)
        # orgs = org.nil? ? Org.select(&:managed?) : [org]
        orgs = org.nil? ? Org.where(managed: true) : [org]

        Parallel.each(orgs, in_threads: threads) do |org_obj|
          months = OrgDateRangeable.split_months_from_creation(org_obj)
          last = months.last
          next if last.blank?

          StatCreatedPlan::CreateOrUpdate.do(
            start_date: last[:start_date],
            end_date: last[:end_date],
            org: org_obj
          )
          StatCreatedPlan::CreateOrUpdate.do(
            start_date: last[:start_date],
            end_date: last[:end_date],
            org: org_obj,
            filtered: true
          )
        end
      end
    end
  end
end
