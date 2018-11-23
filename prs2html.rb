require 'json'
require 'date'

def age(pr)
  (DateTime.now - DateTime.parse(pr["created_at"])).to_i
end

def age_class(pr)
  case age(pr)
  when 0
    "new"
  when 1
    "recent"
  when 2..7
    "normal"
  when 8..15
    "old"
  else
    "stale"
  end
end

xxx = JSON.parse(ARGF.read)

puts <<-EOF
<style>
* { font-family: sans; }
.pull-requests--user {
  display: flex;
}

.pull-requests--user-name {
  width: 150px;
  line-height: 40px;
  height: 40px;
  margin: 4px;
  background-size: 40px 40px;
  background-repeat: no-repeat;
  padding-left: 50px;
}


.pull-requests--user-requests {
  display: flex;
}

.pull-requests--user-requests--request {
  /*width: 160px;*/
  height: 40px;
  margin: 4px;
  padding: 0px 10px;
  line-height: 40px;
  text-align: center;
}

.pull-requests--user-requests--request.new    { background-color: #0DB8B5; }
.pull-requests--user-requests--request.recent { background-color: #6FCC43; }
.pull-requests--user-requests--request.normal { background-color: #FFE433; }
.pull-requests--user-requests--request.old    { background-color: #FC8F12; }
.pull-requests--user-requests--request.stale  { background-color: #D92727; }

.pull-requests--user-requests--request a {
  color: white;
  text-decoration: none;
  font-weight: bold;
}

</style>
<body>
  <div class="pull-requests">
EOF

xxx.each do |user, prs|
  puts <<-EOF
    <div class="pull-requests--user">
      <div class="pull-requests--user-name" style="background-image: url(#{user["avatar_url"]})" >#{user["login"]}</div>
      <div class="pull-requests--user-requests" data-count="#{prs.length}">
  EOF

  prs.sort_by { |pr| pr["number"].to_i }.each do |pr|
    puts <<-EOF
      <div class="pull-requests--user-requests--request #{age_class(pr)}">
        <a href="#{pr["html_url"]}">#{pr.dig("base", "repo", "name")}##{pr["number"]}</a>
      </div>
    EOF
  end

  puts <<-EOF
      </div>
    </div>
  EOF
end

puts <<-EOF
  </div>
</body>
EOF
