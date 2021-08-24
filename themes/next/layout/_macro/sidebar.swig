{% macro render(display_toc) %}
<div class="toggle sidebar-toggle">
  <span class="toggle-line toggle-line-first"></span>
  <span class="toggle-line toggle-line-middle"></span>
  <span class="toggle-line toggle-line-last"></span>
</div>

<aside class="sidebar">
  <div class="sidebar-inner">

    {%- set display_toc = page.toc.enable and display_toc %}
    {%- if display_toc %}
    {%- set toc = toc(page.content, { class: "nav", list_number: page.toc.number, max_depth: page.toc.max_depth }) %}
    {%- set display_toc = toc.length > 1 and display_toc %}
    {%- endif %}

    <ul class="sidebar-nav motion-element">
      <li class="sidebar-nav-toc">
        {{ __('sidebar.toc') }}
      </li>
      <li class="sidebar-nav-overview">
        {{ __('sidebar.overview') }}
      </li>
    </ul>

    <!--noindex-->
    <div class="post-toc-wrap sidebar-panel">
      {%- if display_toc %}
      <div class="post-toc motion-element">{{ toc }}</div>
      {%- endif %}
    </div>
    <!--/noindex-->

    <div class="site-overview-wrap sidebar-panel">
      {{ partial('_partials/sidebar/site-overview.swig', {}, {cache: theme.cache.enable}) }}

      {{- next_inject('sidebar') }}
    </div>

    {%- if theme.sidebar and theme.sidebar.widgets %}
    {%- for widget in theme.sidebar.widgets %}
    {%- if widget.type == 'image' and widget.enable %}
    <div
      style="{%- if widget.width %} width: {{ widget.width }};{%- endif %}{%- if widget.height %} height: {{ widget.height }};{%- endif %}"
      class="sidebar-panel {%- if widget.type == 'image' %} sidebar-panel-image {%- endif %}{%- if widget.enable %} sidebar-panel-active{%- endif %}">
      <a href="{%- if widget.type == 'image' %}{{widget.url}}{%- endif %}">
        <img src="{{ widget.src }}"
             style="{%- if widget.width %} width: {{ widget.width }};{%- endif %}{%- if widget.height %} height: {{ widget.height }};{%- endif %}">
      </a>
    </div>
    {%- endif %}
    {%- if widget.type == 'card' and widget.enable %}
    {%- endif %}
    {%- if widget.type == 'tags' %}
    <div class="sidebar-panel sidebar-panel-tags {%- if widget.enable %} sidebar-panel-active{%- endif %}">
      {%- if widget.name %}
      <h4 class="name">
        {{ widget.name }}
      </h4>
      {%- endif %}
      <div class="content">
        {{ tagcloud({
        amount : theme.tagcloud.amount,
        start_color: theme.tagcloud.start,
        end_color : theme.tagcloud.end})
        }}
      </div>
      <script>
        const tagsColors = ['#00a67c', '#5cb85c', '#d9534f', '#567e95', '#b37333', '#f4843d', '#15a287']
        const tagsElements = document.querySelectorAll('.sidebar-panel-tags .content a')
        tagsElements.forEach((item) => {
          item.style.backgroundColor = tagsColors[Math.floor(Math.random() * tagsColors.length)]
        })
      </script>
    </div>
    {%- endif %}
    {%- if widget.type == 'categories'%}
    <div class="sidebar-panel sidebar-panel-categories {%- if widget.enable %} sidebar-panel-active{%- endif %}">
      {%- if widget.name %}
      <h4 class="name">
        {{ widget.name }}
      </h4>
      {%- endif %}
      <div class="content">
        {{ list_categories({
        depth: -1
        }) }}
      </div>
    </div>
    {%- endif %}
    {%- if widget.type == 'hot' and widget.enable %}

    {%- endif %}
    {%- if widget.type == 'friends' %}
    <div class="sidebar-panel sidebar-panel-friends {%- if widget.enable %} sidebar-panel-active{%- endif %}">
      {%- if widget.name %}
      <h4 class="name">
        {{ widget.name }}
      </h4>
      {%- endif %}
      <ul class="friends">
        {%- for friend in theme.friends %}
        <li class="friend">
          <span class="logo">
            <img src="{{ friend.logo }}">
          </span>
          <span class="link">
            <a href="{{ friend.url }}">{{friend.name}}</a>
          </span>
        </li>
        {%- endfor %}
      </ul>
    </div>
    {%- endif %}
    {%- endfor %}
    {%- endif %}

    {%- if theme.back2top.enable and theme.back2top.sidebar %}
    <div class="back-to-top motion-element">
      <i class="fa fa-arrow-up"></i>
      <span>0%</span>
    </div>
    {%- endif %}

  </div>
</aside>
<div id="sidebar-dimmer"></div>
{% endmacro %}
