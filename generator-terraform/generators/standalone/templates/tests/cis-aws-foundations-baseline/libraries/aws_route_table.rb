class AwsRouteTable < Inspec.resource(1)
  name 'aws_route_table'
  desc 'Verifies settings for an AWS Route Table'
  example <<~EXAMPLE
    describe aws_route_table do
      its('route_table_id') { should cmp 'rtb-05462d2278326a79c' }
    end
  EXAMPLE
  supports platform: 'aws'

  include AwsSingularResourceMixin

  def to_s
    "Route Table #{@route_table_id}"
  end

  attr_reader :associations, :propagating_vgws, :route_table_id, :routes, :tags, :vpc_id, :resp

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:route_table_id],
      allowed_scalar_name: :route_table_id,
      allowed_scalar_type: String,
    )

    if validated_params.key?(:route_table_id) &&
       validated_params[:route_table_id] !~ /^rtb\-([0-9a-f]{17})|(^rtb\-[0-9a-f]{8})$/
      raise ArgumentError,
            'aws_route_table Route Table ID must be in the' \
            ' format "rtb-" followed by 8 or 17 hexadecimal characters.'
    end

    validated_params
  end

  def fetch_from_api
    backend = BackendFactory.create(inspec_runner)

    if @route_table_id.nil?
      args = nil
    else
      args = { filters: [{ name: 'route-table-id', values: [@route_table_id] }] }
    end

    resp = backend.describe_route_tables(args)
    routetable = resp.to_h[:route_tables]

    unless routetable.empty?
      r = routetable.first
      @associations = r[:associations]
      @propagating_vgws = r[:propagating_vgws]
      @route_table_id = r[:route_table_id]
      @routes = r[:routes]
      @tags = r[:tags]
      @vpc_id = r[:vpc_id]
    end
    @exists = !routetable.empty?
  end

  class Backend
    class AwsClientApi < AwsBackendBase
      BackendFactory.set_default_backend(self)
      self.aws_client_class = Aws::EC2::Client

      def describe_route_tables(query)
        aws_service_client.describe_route_tables(query)
      end
    end
  end
end
