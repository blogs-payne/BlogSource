<div class="carousel">
  <div id="wowslider-container">
    <div class="ws_images">
      <ul>
        {%- for item in theme.carousel.content %}
        <li><a target="_blank" href="{{ item.url }}"><img title="{{ item.name }}" src="{{ item.src }}"/></a></li>
        {%- endfor %}
      </ul>
    </div>
    <div class="ws_thumbs">
      <div>
        {%- for item in theme.carousel.content %}
        <a target="_blank" href="#"><img src="{{ item.src }}"/></a>
        {%- endfor %}
      </div>
    </div>
    <div class="ws_shadow"></div>
  </div>
</div>

{% set assets_base_url = '' %}
{% if theme.cdn.jsdelivr.enabled %}
  {% set assets_base_url = 'https://cdn.jsdelivr.net/gh/' + theme.repository + theme.cdn.jsdelivr.version %}
{% endif %}

{%- if theme.carousel.enable %}
{%- set pace_css_uri = assets_base_url + '/lib/wowslide/slide.css' %}
{%- set pace_js_lib_url = assets_base_url + '/lib/wowslide/jquery.min.js' %}
{%- set pace_js_uri = assets_base_url + '/lib/wowslide/slider.js' %}
<link rel="stylesheet" href="{{ pace_css_uri }}">
<script src="{{ pace_js_lib_url }}"></script>
<script src="{{ pace_js_uri }}"></script>
<script>
  jQuery("#wowslider-container").wowSlider({
    effect: "cube",
    prev: "",
    next: "",
    duration: 20 * 100,
    delay: 20 * 100,
    width: 716,
    height: 297,
    autoPlay: true,
    playPause: true,
    stopOnHover: false,
    loop: false,
    bullets: 0,
    caption: true,
    captionEffect: "slide",
    controls: true,
    onBeforeStep: 0,
    images: 0
  });
</script>
{%- endif %}
