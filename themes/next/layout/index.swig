{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template with context %}

{% block title %}{{ title }}{%- if theme.index_with_subtitle and subtitle %}丨{{ subtitle }}{%- endif %}{% endblock %}

{% block class %}index posts-expand{% endblock %}

{% block content %}
  {%- include '_macro/carousel.swig' %}
  {%- for post in page.posts.toArray() %}
    {{ partial('_macro/post.swig', {post: post, is_index: true}) }}
  {%- endfor %}

  <script>
        document.querySelectorAll('.random').forEach(item => item.src="https://picsum.photos/id/" + Math.floor(Math.random() * Math.floor(300)) + "/200/133")
  </script>

  {% include '_partials/pagination.swig' %}

{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}
