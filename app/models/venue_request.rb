class VenueRequest < ApplicationRecord
  has_one_attached :utility_bill

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :street_address, presence: true, length: { minimum: 5, maximum: 200 }
  validates :city, presence: true, length: { minimum: 2, maximum: 50 }
  validates :state, presence: true, inclusion: {
            in: %w[AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY],
          }
  validates :zip_code, presence: true, format: { with: /\A\d{5}(-\d{4})?\z/ }
  validates :category, presence: true, inclusion: {
               in: %w[bar restaurant concert_hall club coffee_shop theater outdoor other],
             }
  validates :requester_type, presence: true, inclusion: { in: %w[artist owner] }
  validates :requester_id, presence: true, numericality: { greater_than: 0 }

  # Owner-specific validations
  validates :owner_phone, presence: true, if: :ownership_claim?
  validates :utility_bill, presence: true, if: :ownership_claim?

  # Rails 8 enum syntax
  enum :status, { pending: 0, approved: 1, rejected: 2, duplicate: 3 }

  def ownership_claim?
    ownership_claim == true
  end

  def full_address
    "#{street_address}, #{city}, #{state} #{zip_code}"
  end

  def requester
    case requester_type
    when "artist"
      Artist.find_by(id: requester_id)
    when "owner"
      Owner.find_by(id: requester_id)
    end
  end

  def approve_and_create_venue!
    return false unless pending?

    begin
      ActiveRecord::Base.transaction do
        # Create the venue
        venue = Venue.create!(
          name: name,
          street_address: street_address,
          city: city,
          state: state,
          zip_code: zip_code,
          website: website,
          category: category,
        )

        # If this is an ownership claim, assign the owner
        if ownership_claim? && requester_type == "owner"
          venue.update!(owner_id: requester_id)
        end

        # Geocode the venue if geocoding is available
        venue.geocode if venue.respond_to?(:geocode)

        # Update request status
        update!(status: :approved, venue_id: venue.id)

        venue
      end
    rescue => e
      Rails.logger.error "Failed to approve venue request #{id}: #{e.message}"
      false
    end
  end
end
