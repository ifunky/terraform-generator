title 'AWS Networking Recommendations'

control 'aws-networking-01' do
  impact 0.7
  title 'No security groups should be world-open on port 22'

  aws_security_groups.group_ids.each do |sg_id|
    describe aws_security_group(group_id: sg_id) do
      it { should_not allow_in(ipv4_range: '0.0.0.0/0', port: 22) }
    end
  end
end

control 'aws-networking-02' do
  impact 0.7
  title 'No security groups should be world-open on port 3389'
  
  aws_security_groups.group_ids.each do |sg_id|
    describe aws_security_group(group_id: sg_id) do
      it { should_not allow_in(ipv4_range: '0.0.0.0/0', port: 3389) }
    end
  end
end