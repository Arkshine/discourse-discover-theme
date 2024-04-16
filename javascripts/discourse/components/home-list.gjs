import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import LoadMore from "discourse/components/load-more";
import bodyClass from "discourse/helpers/body-class";
import dIcon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";

export default class HomeList extends Component {
  @service store;
  @service siteSettings;
  @service homepageFilter;

  parseJSON = (str) => {
    try {
      return JSON.parse(str);
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("Error parsing JSON:", error);
      return {};
    }
  };

  @action
  loadMore() {
    if (this.homepageFilter.hasMoreResults) {
      this.homepageFilter.getSiteList();
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{bodyClass "discover-home"}}

    <ul class="discover-list" {{didInsert this.homepageFilter.getSiteList}}>
      {{#if this.homepageFilter.topicResults}}
        {{#each this.homepageFilter.topicResults as |topic|}}
          <li class="discover-list__item">
            <a
              href={{topic.featured_link}}
              target="_blank"
              rel="noopener noreferrer"
              class="discover-list__item-link"
            >
              <img
                class="discover-list__item-banner"
                srcset={{topic.bannerImage.srcset}}
                src={{topic.bannerImage.src}}
                sizes={{topic.bannerImage.sizes}}
              />
              <div class="discover-list__item-content">
                <h2>
                  <img
                    class="discover-list__item-logo"
                    src={{topic.image_url}}
                  />
                  {{topic.title}}
                </h2>
                <div class="discover-list__item-meta">
                  {{#if topic.topics_30_days}}
                    <span>{{dIcon "comments"}}{{topic.topics_30_days}}</span>
                  {{/if}}
                  {{#if topic.users_30_days}}
                    <span>{{dIcon "user"}}
                      {{topic.users_30_days}}</span>
                  {{/if}}
                </div>
                <p class="discover-list__item-excerpt">
                  {{topic.excerpt}}
                </p>
              </div>
            </a>
          </li>
        {{/each}}
        <LoadMore @selector=".discover-list__item" @action={{this.loadMore}} />
      {{else}}
        <ConditionalLoadingSpinner @condition={{this.homepageFilter.loading}}>
          <li class="no-results">
            {{i18n (themePrefix "search.no_results")}}
            {{#if this.homepageFilter.searchQuery}}
              —
              <a {{on "click" this.homepageFilter.resetSearch}}>
                {{i18n (themePrefix "search.remove_filter")}}
              </a>{{/if}}
          </li>
          {{bodyClass "--no-results"}}
        </ConditionalLoadingSpinner>
      {{/if}}
    </ul>
  </template>
}
