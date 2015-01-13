Pod::Spec.new do |s|
  s.name                  = 'CCNStatusItemView'
  s.version               = '0.1.5'
  s.summary               = 'CCNStatusItemView is a subclass of NSView to act as a custom view for NSStatusItem.'
  s.homepage              = 'https://github.com/phranck/CCNStatusItemView'
  s.author                = { 'Frank Gregor' => 'phranck@cocoanaut.com' }
  s.source                = { :git => 'https://github.com/phranck/CCNStatusItemView.git', :tag => s.version.to_s }
  s.osx.deployment_target = '10.9'
  s.requires_arc          = true
  s.source_files          = 'CCNStatusItemView/*.{h,m}'
  s.license               = { :type => 'MIT' }
end
