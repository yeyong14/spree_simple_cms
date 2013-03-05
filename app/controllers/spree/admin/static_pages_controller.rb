module Spree
  module Admin
    class StaticPagesController < ResourceController
      def index
        respond_with(@collection) do |format|
          format.html
          format.json { render :json => json_data }
        end
      end
      
      def show
        redirect_to( :action => :edit )
      end

      def published
        sp = Spree::StaticPage.find(params[:id])

        if sp.update_attribute(:published_at, Time.now)
          flash[:notice] = t("info_published_static_page")
        else
          flash[:error] = t("error_published_static_page")
        end
        redirect_to spree.admin_static_pages_path
      end

      def in_nav_menu
        sp = Spree::StaticPage.find(params[:id])

        if sp.update_attribute(:in_nav_menu, true)
          flash[:notice] = t("info_in_nav_menu_static_page")
        else
          flash[:error] = t("error_in_nav_menu_static_page")
        end
        redirect_to spree.admin_static_pages_path
      end

      def update_positions
        params[:positions].each do |id, index|
          Spree::StaticPage.update_all(['position=?', index], ['id=?', id])
        end

        respond_to do |format|
          format.js { render :text => 'Ok' }
        end
      end

      protected
      def location_after_save
        edit_admin_static_page_url(@static_page)
      end
      
      def collection
        return @collection if @collection.present?
        params[:q] ||= {}

        params[:q][:s] ||= "name asc"

        @search = super.ransack(params[:q])
        @collection = @search.result.
            published.
            page(params[:page]).
            per(Spree::Config[:admin_products_per_page])
      end
    end
  end
end