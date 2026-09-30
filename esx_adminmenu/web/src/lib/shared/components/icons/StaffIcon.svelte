<script lang="ts">
	const { class: className } = $props<{ class?: string }>();
</script>

<svg class={`data-component-icon ${className ?? ""}`} viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
	<path d="M9 9.2a2.7 2.7 0 1 0 0-5.4 2.7 2.7 0 0 0 0 5.4Z" stroke="currentColor" stroke-width="1.6"/>
	<path d="M3.4 14.6c.7-2.2 2.8-3.6 5.6-3.6s4.9 1.4 5.6 3.6" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
	<path d="M13.2 3.2 14.4 4.4 16.6 2.2" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
