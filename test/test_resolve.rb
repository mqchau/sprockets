require 'sprockets_test'

class TestResolve < Sprockets::TestCase
  def setup
    @env = Sprockets::Environment.new(".")
  end

  test "resolve compat in default environment" do
    @env.append_path(fixture_path('default'))

    assert_equal fixture_path('default/gallery.js'),
      @env.resolve("gallery.js", compat: true)
    assert_equal fixture_path('default/coffee/foo.coffee'),
      @env.resolve("coffee/foo.js", compat: true)
    assert_equal fixture_path('default/jquery.tmpl.min.js'),
      @env.resolve("jquery.tmpl.min", compat: true)
    assert_equal fixture_path('default/jquery.tmpl.min.js'),
      @env.resolve("jquery.tmpl.min.js", compat: true)
    assert_equal fixture_path('default/manifest.js.yml'),
      @env.resolve('manifest.js.yml', compat: true)
    refute @env.resolve("null", compat: true)
  end

  test "resolve compat accept type list before paths" do
    @env.append_path(fixture_path('resolve/javascripts'))
    @env.append_path(fixture_path('resolve/stylesheets'))

    assert_equal fixture_path('resolve/javascripts/foo.js'),
      @env.resolve('foo', accept: 'application/javascript', compat: true)
    assert_equal fixture_path('resolve/stylesheets/foo.css'),
      @env.resolve('foo', accept: 'text/css', compat: true)

    assert_equal fixture_path('resolve/javascripts/foo.js'),
      @env.resolve('foo', accept: 'application/javascript, text/css', compat: true)
    assert_equal fixture_path('resolve/javascripts/foo.js'),
      @env.resolve('foo', accept: 'text/css, application/javascript', compat: true)

    assert_equal fixture_path('resolve/javascripts/foo.js'),
      @env.resolve('foo', accept: 'application/javascript; q=0.8, text/css', compat: true)
    assert_equal fixture_path('resolve/javascripts/foo.js'),
      @env.resolve('foo', accept: 'text/css; q=0.8, application/javascript', compat: true)

    assert_equal fixture_path('resolve/javascripts/foo.js'),
      @env.resolve('foo', accept: '*/*; q=0.8, application/javascript', compat: true)
    assert_equal fixture_path('resolve/javascripts/foo.js'),
      @env.resolve('foo', accept: '*/*; q=0.8, text/css', compat: true)
  end

  test "resolve compat under load path" do
    @env.append_path(scripts = fixture_path('resolve/javascripts'))
    @env.append_path(styles = fixture_path('resolve/stylesheets'))

    assert_equal fixture_path('resolve/javascripts/foo.js'),
      @env.resolve('foo.js', load_paths: [scripts], compat: true)
    assert_equal fixture_path('resolve/stylesheets/foo.css'),
      @env.resolve('foo.css', load_paths: [styles], compat: true)

    refute @env.resolve('foo.js', load_paths: [styles], compat: true)
    refute @env.resolve('foo.css', load_paths: [scripts], compat: true)
  end

  test "resolve compat absolute" do
    @env.append_path(fixture_path('default'))

    assert_equal fixture_path('default/gallery.js'),
      @env.resolve(fixture_path('default/gallery.js'), compat: true)
    assert_equal fixture_path('default/gallery.js'),
      @env.resolve(fixture_path('default/app/../gallery.js'), compat: true)
    assert_equal fixture_path('default/gallery.js'),
      @env.resolve(fixture_path('default/gallery.js'), accept: 'application/javascript', compat: true)

    refute @env.resolve(fixture_path('default/asset/POW.png'), compat: true)
    refute @env.resolve(fixture_path('default/missing'), compat: true)
    refute @env.resolve(fixture_path('default/gallery.js'), accept: 'text/css', compat: true)
  end

  test "resolve compat absolute identity" do
    @env.append_path(fixture_path('default'))

    @env.stat_tree(fixture_path('default')).each do |path, stat|
      next unless stat.file?
      assert_equal path, @env.resolve(path, compat: true)
    end
  end

  test "resolve compat extension before accept type" do
    @env.append_path(fixture_path('resolve/javascripts'))
    @env.append_path(fixture_path('resolve/stylesheets'))

    assert_equal fixture_path('resolve/javascripts/foo.js'),
      @env.resolve('foo.js', accept: 'application/javascript', compat: true)
    assert_equal fixture_path('resolve/stylesheets/foo.css'),
      @env.resolve('foo.css', accept: 'text/css', compat: true)

    assert_equal fixture_path('resolve/javascripts/foo.js'),
      @env.resolve('foo.js', accept: '*/*', compat: true)
    assert_equal fixture_path('resolve/stylesheets/foo.css'),
      @env.resolve('foo.css', accept: '*/*', compat: true)

    assert_equal fixture_path('resolve/javascripts/foo.js'),
      @env.resolve('foo.js', accept: 'text/css, */*', compat: true)
    assert_equal fixture_path('resolve/stylesheets/foo.css'),
      @env.resolve('foo.css', accept: 'application/javascript, */*', compat: true)
  end

  test "resolve compat accept type quality in paths" do
    @env.append_path(fixture_path('resolve/javascripts'))

    assert_equal fixture_path('resolve/javascripts/bar.js'),
      @env.resolve('bar', accept: 'application/javascript', compat: true)
    assert_equal fixture_path('resolve/javascripts/bar.css'),
      @env.resolve('bar', accept: 'text/css', compat: true)

    assert_equal fixture_path('resolve/javascripts/bar.js'),
      @env.resolve('bar', accept: 'application/javascript, text/css', compat: true)
    assert_equal fixture_path('resolve/javascripts/bar.css'),
      @env.resolve('bar', accept: 'text/css, application/javascript', compat: true)

    assert_equal fixture_path('resolve/javascripts/bar.css'),
      @env.resolve('bar', accept: 'application/javascript; q=0.8, text/css', compat: true)
    assert_equal fixture_path('resolve/javascripts/bar.js'),
      @env.resolve('bar', accept: 'text/css; q=0.8, application/javascript', compat: true)

    assert_equal fixture_path('resolve/javascripts/bar.js'),
      @env.resolve('bar', accept: '*/*; q=0.8, application/javascript', compat: true)
    assert_equal fixture_path('resolve/javascripts/bar.css'),
      @env.resolve('bar', accept: '*/*; q=0.8, text/css', compat: true)
  end

  test "resolve asset uri" do
    @env.append_path(fixture_path('default'))

    assert_equal "file://#{fixture_path('default/gallery.js')}?type=application/javascript",
      @env.resolve("gallery.js", compat: false).first
    assert_equal "file://#{fixture_path('default/coffee/foo.coffee')}?type=application/javascript",
      @env.resolve("coffee/foo.js", compat: false).first
    assert_equal "file://#{fixture_path('default/manifest.js.yml')}?type=text/yaml",
      @env.resolve("manifest.js.yml", compat: false).first

    assert_equal "file://#{fixture_path('default/gallery.js')}?type=application/javascript",
      @env.resolve("gallery", accept: 'application/javascript', compat: false).first
  end

  test "resolve asset uri under load path" do
    @env.append_path(scripts = fixture_path('resolve/javascripts'))
    @env.append_path(styles = fixture_path('resolve/stylesheets'))

    assert_equal "file://#{fixture_path('resolve/javascripts/foo.js')}?type=application/javascript",
      @env.resolve('foo.js', load_paths: [scripts], compat: false).first
    assert_equal "file://#{fixture_path('resolve/stylesheets/foo.css')}?type=text/css",
      @env.resolve('foo.css', load_paths: [styles], compat: false).first

    refute @env.resolve('foo.js', load_paths: [styles], compat: false)
    refute @env.resolve('foo.css', load_paths: [scripts], compat: false)
  end

  test "resolve absolute identity" do
    @env.append_path(fixture_path('default'))

    @env.stat_tree(fixture_path('default')).each do |path, stat|
      next unless stat.file?
      assert uri = @env.resolve(path, compat: false).first
      assert_equal uri, @env.resolve(uri, compat: false).first
    end
  end

  test "verify all logical paths" do
    Dir.entries(Sprockets::TestCase::FIXTURE_ROOT).each do |dir|
      unless %w( . ..).include?(dir)
        @env.append_path(fixture_path(dir))
      end
    end

    @env.logical_paths.each do |logical_path, filename|
      assert_equal filename, @env.resolve(logical_path, compat: true),
        "Expected #{logical_path.inspect} to resolve to #{filename}"
    end
  end

  test "legacy logical path iterator with matchers" do
    @env.append_path(fixture_path('default'))

    assert_equal ["application.js", "gallery.css"],
      @env.each_logical_path("application.js", /gallery\.css/).to_a
  end
end
