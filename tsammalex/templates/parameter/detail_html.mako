<%inherit file="../${context.get('request').registry.settings.get('clld.app_template', 'app.mako')}"/>
<%namespace name="util" file="../util.mako"/>
<%! active_menu_item = "parameters" %>
<%block name="title">${_('Parameter')} ${ctx.name} (${ctx.description})</%block>

% if ctx.family or ctx.genus:
<ul class="breadcrumb">
    <li class="active">${ctx.name} <span class="divider">/</span></li>
    % if ctx.genus:
        <li class="active">Order: ${ctx.genus} <span class="divider">/</span></li>
    % endif
    % if ctx.family:
    <li class="active">Family: ${ctx.family}</li>
    % endif
</ul>
% endif

<div style="float: right; margin-top: 10px;">
    ${h.alt_representations(request, ctx, doc_position='left', exclude=['md.html'])}
</div>


<h2>${ctx.description or ctx.name}</h2>

<div class="row-fluid">
    <div class="span7">
<table class="table table-condensed table-nonfluid">
    <tbody>
        ##% if ctx.genus:
        ##    <tr>
        ##        <td>Order:</td>
        ##        <td>${ctx.genus}</td>
        ##    </tr>
        ##% endif
        ##% if ctx.family:
        ##    <tr>
        ##        <td>Family:</td>
        ##        <td>${ctx.family}</td>
        ##    </tr>
        ##% endif
        <tr>
            <td>Common categories (Eng):</td>
            <td>
                <ul class="unstyled">
                    % for c in ctx.categories:
                        <li>${c.name}</li>
                    % endfor
                </ul>
            </td>
        </tr>
        <tr>
            <td>Countries:</td>
            <td>
                <ul class="unstyled">
                    % for c in ctx.countries:
                        <li>${c.name} (${c.id})</li>
                    % endfor
                </ul>
            </td>
        </tr>
        <tr>
            <td>
                <a href="${request.route_url('ecoregions')}">Ecoregions</a>:
            </td>
            <td>
                <ul class="unstyled">
                    % for er in ctx.ecoregions:
                    <li>${er.id} ${er.name}</li>
                    % endfor
                </ul>
            </td>
        </tr>
        <tr>
            <td>Links:</td>
            <td>
                <ul class="inline">
                    % if ctx.eol_url:
                        <li>
                <span class="large label label-info">
                    ${h.external_link(ctx.eol_url, 'eol', inverted=True, style="color: white;",)}
                </span>
                        </li>
                    % endif
                    % if ctx.wikipedia_url:
                        <li>
            <span class="large label label-info">
                ${h.external_link(ctx.wikipedia_url, 'wikipedia', inverted=True, style="color: white;")}
            </span>
                        </li>
                    % endif
                </ul>
            </td>
        </tr>
    </tbody>
</table>
    </div>
    <div class="span5 well well-small pull-right">
        ${request.map.render()}
    </div>
</div>

<% files = [f_ for f_ in ctx._files if f_.name.startswith('small') or f_.name.startswith('large')] %>

% for chunk in [files[i:i + 3] for i in range(0, len(files), 3)]:
<div class="row-fluid">
    % for f in chunk:
        <div class="span4">
            <div class="well">
                <img src="${request.file_url(f)}" class="image"/>
            </div>
            <table class="table table-condensed">
                <tbody>
                    % for attr in 'source date place author permission comments'.split():
                        % if f.jsondata.get(attr):
                            <% value = f.jsondata[attr] %>
                            <tr>
                                <td>${attr.capitalize()}:</td>
                                <td>
                                    % if attr == 'permission':
                        % if value.get('license'):
                                                                                          ${h.external_link(value['license'][0], value['license'][1])}
                                    % endif
                                    % elif attr == 'source':
                        ${value|n}
                                    % else:
                        ${value}
                                    % endif
                                </td>
                            </tr>
                        % endif
                    % endfor
                </tbody>
            </table>
        </div>
    % endfor
</div>
    <hr/>
% endfor

${request.get_datatable('values', h.models.Value, parameter=ctx).render()}
