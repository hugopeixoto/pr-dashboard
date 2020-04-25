require_relative "./github.rb"

def prs_by_reviewer(access_token, organization)
  gh = GitHub.new(access_token)

  gh.repos(organization)
    .flat_map { |repo| gh.pull_requests(repo["full_name"]).to_a }
    .flat_map { |pr| pr["requested_reviewers"].map { |reviewer| { reviewer: reviewer, pr: pr } } }
    .group_by { |review| review[:reviewer] }
    .transform_values { |reviews| reviews.map { |r| r[:pr] } }
    .to_a
end

if __FILE__ == $0
  puts JSON.generate(prs_by_reviewer(ARGV.fetch(0), ARGV.fetch(1)))
end
